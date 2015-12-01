class ArtworkRequest < ActiveRecord::Base
  include TrackingHelpers
  include IntegratedCrms

  acts_as_paranoid
  acts_as_warnable

  tracked by_current_user + on_order

  searchable do
    text :order_name, :job_names, :ink_color_names,
         :artwork_names, :artwork_descriptions,
         :artist_full_name, :salesperson_full_name

    string :state

    date :deadline
    date :order_in_hand_by
  end

  PRIORITIES = {
    1 => 'High (Rush Job)',
    3 => 'Customer Paid For Art',
    5 => 'Normal',
    7 => 'Low'
  }

  default_scope { order(deadline: :asc).order(priority: :desc) }
  scope :unassigned, -> { where("artist_id is null") }
  scope :pending, -> { where.not(state: 'art created') }

  has_many :artwork_request_artworks
  has_many :artwork_request_ink_colors
  has_many :artwork_request_imprints
  belongs_to :artist,                class_name: User
  belongs_to :salesperson,           class_name: User
  belongs_to :approved_by,           class_name: User
  has_many   :artworks,              through: :artwork_request_artworks
  has_many   :proofs,                through: :artworks
  has_many   :assets,                as: :assetable, dependent: :destroy
  has_many   :ink_colors,            through: :artwork_request_ink_colors
  has_many   :imprints,              through: :artwork_request_imprints
  has_many   :jobs,                  through: :imprints
  has_many   :imprint_methods,       through: :imprints
  has_many   :print_locations,       through: :imprints
  has_many   :potential_ink_colors,  through: :imprint_methods, source: :ink_colors

  accepts_nested_attributes_for :assets, allow_destroy: true

  validates :state,          presence: true
  validates :deadline,       presence: true
  validates :description,    presence: true
  validates :ink_colors,     presence: true
  validates :imprints,       presence: true
  validates :priority,       presence: true
  validates :salesperson,    presence: true

  after_create :enqueue_create_freshdesk_proof_ticket if Rails.env.production?
  before_save :transition_to_assigned, if: :should_assign?

  attr_accessor :current_user

  state_machine :state, initial: :unassigned do
    after_transition any => any do |artwork_request|
      artwork_request.touch
    end

    after_transition on: [:reject_artwork, :reject_artwork_request] do |artwork_request|
      artwork_request.update_column(:approved_by_id, nil)
    end

    after_transition on: :reject_artwork do |artwork_request|
      artwork_request.order.artwork_rejected
    end

    before_transition on: :unassigned_artist do |artwork_request|
      artwork_request.update_column(:artist_id, nil)
    end

    after_transition on: :reject_artwork_request do |artwork_request|
      artwork_request.order.issue_warning(
        "Bad Artwork Request",
        "Artwork Request ##{artwork_request.id} was determined to be inadequate."\
        " A reason for rejection is available on the order timeline."\
        " Please revise it and mark it as revised."
      )
    end

    after_transition on: :revise_artwork_request do |artwork_request|
      artwork_request.order.artwork_requests_complete unless artwork_request.order.missing_artwork_requests?
    end

    event :assigned_artist do
      transition :unassigned => :pending_artwork
      transition :artwork_request_rejected => :artwork_request_rejected
      transition :artwork_rejected => :artwork_rejected
      transition :pending_artwork => :pending_artwork
      transition :pending_manager_approval => :pending_manager_approval
      transition :manager_approved => :manager_approved
    end

    event :unassigned_artist do
      transition any => :unassigned
    end

    event :artwork_added do
      transition :pending_artwork => :pending_manager_approval
      transition :artwork_rejected => :pending_manager_approval
    end

    event :artwork_removed do
      transition :pending_manager_approval => :pending_manager_approval,  :unless => lambda{ |artwork_request| artwork_request.artworks.empty? }
      transition :manager_approved => :pending_manager_approval,  :unless => lambda{ |artwork_request| artwork_request.artworks.empty? }
      transition :pending_manager_approval => :pending_artwork,  :if =>  lambda{ |artwork_request| artwork_request.artworks.empty? }
    end

    event :approved do
      transition :pending_manager_approval => :manager_approved
    end

    event :reject_artwork_request do
      transition all => :artwork_request_rejected
    end

    event :revise_artwork_request do
      transition :artwork_request_rejected => :unassigned, :if => lambda{|artwork_request| artwork_request.artist.blank? }
      transition :artwork_request_rejected => :pending_artwork, :if => lambda{|artwork_request| artwork_request.artworks.empty? && !artwork_request.artist.blank? }
      transition :artwork_request_rejected => :pending_manager_approval, :unless => lambda{|artwork_request| artwork_request.artworks.empty? || artwork_request.artist.blank? }
    end

    event :reject_artwork do
      transition :pending_manager_approval => :artwork_rejected
      transition :manager_approved => :artwork_rejected
    end

    state :pending_manager_approval, :manager_approved do
      validates :artworks, presence: true
    end

    state :manager_approved do
      validates :approved_by, presence: true
    end

  end

  def assigned_artist(artist)
    update_column(:artist_id, (artist.id rescue artist))
    super
  end

  def name
  end

  def order
    if jobs.respond_to?(:where)
      @order ||= jobs.where.not(jobbable_id: nil).first.try(:jobbable)
    else
      @order ||= jobs.find { |j| !j.jobbable_id.nil? }.try(:jobbable)
    end
  end

  def artist_full_name
    artist.try(:full_name)
  end

  def salesperson_full_name
    salesperson.try(:full_name)
  end

  def order_in_hand_by
    order.try(:in_hand_by)
  end

  def order_name
    order.try(:name) || 'broken'
  end

  def job_names
    jobs.pluck(:name).join(', ')
  end

  def ink_color_names
    ink_colors.pluck(:name).join(', ')
  end

  def artwork_names
    artworks.pluck(:name).join(', ')
  end
  def artwork_descriptions
    artworks.pluck(:description).join(', ')
  end

  def ink_color_ids=(ids)
    custom_ids = []
    ids.reject! do |custom_name|
      next if /^\d+$/ =~ custom_name.to_s

      custom_ink_color = InkColor.find_or_initialize_by(
        name: custom_name
      )
      if custom_ink_color.new_record?
        custom_ink_color.custom = true
        custom_ink_color.imprint_methods = imprint_methods
        custom_ink_color.save!
      end

      custom_ids << custom_ink_color.id.to_s
    end
    super(ids + custom_ids)
  end

  def imprintable_variant_count
    jobs.map(&:imprintable_variant_count).reduce(:+)
  end

  def imprintable_info
    jobs.map(&:imprintable_info).join(', ')
  end

  def imprintable_proofing_templates
    jobs.map(&:imprintables_for_order).flatten.map(&:proofing_template_name).uniq
  end

  def imprintable_proofing_templates_for_job(job)
    job.imprintables_for_order.map(&:proofing_template_name).uniq
  end

  def print_location_names_for_job(job)
    print_locations_for_job(job).map(&:name)
  end

  def print_locations_for_job(job)
    imprints.where(job_id: job.id).map(&:print_location)
  end

  def max_ideal_print_location_size_for_job(job)
    print_location_ids = imprints.where(job_id: job.id).pluck(:print_location_id)
    print_location_imprintables = jobs.map{|x| x.imprintables_for_order }.flatten
    .map{|x| x.print_location_imprintables.where(print_location_id: print_location_ids) }
    .flatten
    width = print_location_imprintables.map(&:ideal_imprint_width).min
    height = print_location_imprintables.map(&:ideal_imprint_height).min
    { width: width , height: height }
  end

  def max_print_location_size
    print_location_ids = imprints.pluck(:print_location_id)
    print_location_imprintables = jobs.map{|x| x.imprintables_for_order }.flatten
    .map{|x| x.print_location_imprintables.where(print_location_id: print_location_ids) }
    .flatten
    width = print_location_imprintables.map(&:max_imprint_width).min
    height = print_location_imprintables.map(&:max_imprint_height).min
    { width: width , height: height }
  end

  def imprintables_for_job_with_proofing_template(job, proofing_template_name)
    job.imprintables_for_order.where(proofing_template_name: proofing_template_name)
  end

  def colors_for_imprintable_for_job(imprintable, job)
    job.imprintable_variants
      .where(imprintable_id: imprintable.id)
      .map(&:color).map(&:name).uniq
  end

  def max_print_area(print_location)
    max = max_print_location_size
    "#{max[:width]} in. x #{max[:height]} in."
  end

  def total_quantity
    jobs.map(&:total_quantity).reduce(:+)
  end

  def print_location
    print_locations.first
  end

  def imprint_method
    imprint_methods.first
  end

  def imprint_method_names
    imprint_methods.map{|im| im.name }.uniq
  end

  def compatible_ink_colors
    InkColor.compatible_with(imprint_methods)
  end

  def no_proof_ticket_id_entered?
    freshdesk_proof_ticket_id.blank?
  end

  def no_fd_login?(current_user)
    config = FreshdeskModule.get_freshdesk_config(current_user)
    if config.has_key?(:freshdesk_email) && config.has_key?(:freshdesk_password)
      false
    else
      true
    end
  end

  def enqueue_create_freshdesk_proof_ticket
    delay(queue: 'api').create_freshdesk_proof_ticket if
            (should_access_third_parties? && order.freshdesk_proof_ticket_id.blank?)
  end
  warn_on_failure_of :enqueue_create_freshdesk_proof_ticket

  def has_freshdesk_proof_ticket?(current_user)
    response = get_freshdesk_proof_ticket current_user
    response.quote_fd_id_configured ? false : true
  end

  # this function assumes that the following functions are called beforehand
  # with the same user (and therefore doesn't bother checking if they're true or false):
  #   no_ticket_id_entered
  #   no_fd_login
  def get_freshdesk_proof_ticket(current_user)
    # logic for getting freshdesk ticket
    # Once it grabs ticket, if CRM Quote ID not set, set it
    # https://github.com/AnnArborTees/softwear-mockbot/blob/release-2014-10-17/app/models/spree/store.rb
    # Rails.cache.fetch(:order_proof_fd_ticket, :expires => 15.minutes) do
      config = FreshdeskModule.get_freshdesk_config(current_user)
      client = Freshdesk.new(config[:freshdesk_url], config[:freshdesk_email], config[:freshdesk_password])
      client.response_format = 'json'

      ticket = client.get_tickets(order.freshdesk_proof_ticket_id)
      ticket = '{ "quote_fd_id_configured": "false" }' if ticket.nil?
      return OpenStruct.new JSON.parse(ticket)
    # end
  end

  def create_freshdesk_proof_ticket
    return if freshdesk.nil? || !order.freshdesk_proof_ticket_id.blank?

    requester_info = {
      email: order.email,
      phone: format_phone(order.phone_number),
      name:  order.full_name
    }

    ticket = JSON.parse(freshdesk.post_tickets(
        helpdesk_ticket: {
          source: 2,
          group_id: FD_ART_GROUP_ID,
          ticket_type: 'Proofing Convo',
          subject: "Your Ann Arbor T-Shirt Company Order Proof(s) for \"#{order.name}\" ##{order.id} Are Ready",
          custom_field: {
            FD_PROOF_CREATION_STATUS => 'Proof(s) Not Ready',
            FD_NO_OF_DECORATIONS_FIELD => order.imprints.count,
            FD_NO_OF_PROOFS => order.jobs.count,
            FD_ORDER_QTY => order.jobs.map(&:imprintable_line_items_total).inject(:+)
          }
        }
         .merge(requester_info)
      ))
      .try(:[], 'helpdesk_ticket')

    order.update_column(:freshdesk_proof_ticket_id, ticket.try(:[], 'display_id'))
    ticket
  end
  warn_on_failure_of :create_freshdesk_proof_ticket, raise_anyway: true

  def has_proof_pending_approval?
    proofs.where(state: 'emailed_customer').exists?
  end

  def has_approved_proof?
    proofs.where(state: 'customer_approved').exists?
  end

  def transition_to_assigned
    assigned_artist(artist)
  end

  def should_assign?
    artist_id_was.nil? && artist_id_changed? && state == 'unassigned'
  end

end
