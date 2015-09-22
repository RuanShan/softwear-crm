class ArtworkRequest < ActiveRecord::Base
  include TrackingHelpers
  include IntegratedCrms

  acts_as_paranoid
  acts_as_warnable

  tracked by_current_user + on_order

  PRIORITIES = {
    1 => 'High (Rush Job)',
    3 => 'Customer Paid For Art',
    5 => 'Normal',
    7 => 'Low'
  }

  STATUSES = [
    'Pending',
    'In Progress',
    'Art Created'
  ]
 
  default_scope { order(deadline: :asc).order(priority: :desc) }
  scope :unassigned, -> { where("artist_id is null or artist_id = ?", (User.find_by(last_name: 'Lawcock').id rescue nil)) }
  scope :pending, -> { where.not(artwork_status: 'art created') } 

  has_many :artwork_request_artworks
  has_many :artwork_request_ink_colors
  has_many :artwork_request_imprints
  belongs_to :artist,                class_name: User
  belongs_to :salesperson,           class_name: User
  has_many   :artworks,              through: :artwork_request_artworks
  has_many   :proofs,                through: :artworks
  has_many   :assets,                as: :assetable, dependent: :destroy
  has_many   :ink_colors,            through: :artwork_request_ink_colors
  has_many   :imprints,              through: :artwork_request_imprints
  has_many   :jobs,                  through: :imprints
  has_many   :imprint_methods,       through: :imprints
  has_many   :print_locations,       through: :imprints
  has_many   :potential_ink_colors, through: :imprint_methods, source: :ink_colors

  accepts_nested_attributes_for :assets, allow_destroy: true

  validates :artist,         presence: true
  validates :artwork_status, presence: true
  validates :deadline,       presence: true
  validates :description,    presence: true
  validates :ink_colors,     presence: true
  validates :imprints,       presence: true
  validates :priority,       presence: true
  validates :salesperson,    presence: true

  after_create :enqueue_create_freshdesk_proof_ticket
  
  def name
    
  end

  def ink_color_ids=(ids)
    custom_ids = []
    ids.reject! do |custom_name|
      unless /^\d+$/ =~ custom_name.to_s
        custom_ink_color = InkColor.create!(
          name:   custom_name,
          custom: true,
          imprint_methods: imprint_methods
        )
          .id.to_s
        custom_ids << custom_ink_color
      end
    end
    super(ids + custom_ids)
  end

  def imprintable_variant_count
    jobs.map(&:imprintable_variant_count).reduce(:+)
  end

  def imprintable_info
    jobs.map(&:imprintable_info).join(', ')
  end

  def max_print_area(print_location)
    areas = jobs.map{ |j| j.max_print_area(print_location) }
    max_width = areas.map(&:first).min
    max_height = areas.map(&:last).min
    "#{max_width.to_s} in. x #{max_height.to_s} in."
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

  def compatible_ink_colors
    InkColor.compatible_with(imprint_methods)
  end
 
  def order
    self.imprints.first.job.order
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
    self.delay(queue: 'api').create_freshdesk_proof_ticket if 
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
      name: order.full_name
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
end
