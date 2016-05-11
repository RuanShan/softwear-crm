class Order < ActiveRecord::Base
  include TrackingHelpers
  include ProductionCounterpart
  include Softwear::Auth::BelongsToUser
  include Softwear::Lib::Enqueue

  acts_as_paranoid
  acts_as_commentable :public, :private
  acts_as_warnable

  is_activity_recipient

  searchable do
    text :name, :email, :firstname, :lastname, :invoice_state, :proof_state, :artwork_state,
         :company, :twitter, :terms, :delivery_method, :salesperson_full_name, :customer_key

    text :id do
      self[:id].to_s
    end

    text :jobs do
      jobs.map { |j| "#{j.name} #{j.description}" }
    end

    [
      :firstname, :lastname, :email, :terms, :name,
      :delivery_method, :company, :phone_number, :artwork_state,
      :payment_status, :invoice_state, :production_state,
      :notification_state,  :salesperson_full_name
    ]
      .each { |f| string f }

    double :total
    double :commission_amount

    integer :warnings_count

    boolean :balance do
      balance != 0
    end

    double :balance_amount do
      balance
    end

    date :in_hand_by

    boolean :fba do
      fba?
    end

    boolean :canceled

    #reference :salesperson
    integer :salesperson_id
    integer :id
  end

  tracked by_current_user

  ID_FIELD_TEXT = "DO NOT ENTER ANYTHING INTO THIS FIELD UNLESS YOU'RE KARSTEN"

  FBA_CONTACT_EMAIL = 'fba@annarbortees.com'

  VALID_INVOICE_STATES = [
    'pending',
    'approved',
    'rejected',
    'canceled'
  ]

  VALID_PRODUCTION_STATES = %w(
    pending in_production complete canceled
  )

  VALID_PAYMENT_TERMS = [
    '',
    'Paid in full on purchase',
    'Half down on purchase',
    'Paid in full on pick up',
    'Net 30',
    'Net 60',
    'Fulfilled by Amazon'
  ]

  VALID_DELIVERY_METHODS = [
    'Pick up in Ann Arbor',
    'Pick up in Ypsilanti',
    'Ship to one location',
    'Ship to multiple locations'
  ]

  VALID_PAYMENT_STATUSES = [
    'Awaiting Payment',
    'Payment Terms Met',
    'Payment Terms Pending',
    'canceled'
  ]

  VALID_PROOF_STATES = [
    :pending_artwork_requests,
    :pending,
    :submitted_to_customer,
    :rejected,
    :approved,
    :canceled
  ]


  belongs_to_user_called :salesperson
  belongs_to :store
  belongs_to :contact, class_name: 'Crm::Contact'
  has_many :jobs, as: :jobbable, dependent: :destroy, inverse_of: :jobbable
  has_many :line_items, through: :jobs, source: :line_items
  has_many :artwork_requests, through: :jobs, dependent: :destroy
  has_many :artworks, through: :artwork_requests
  has_many :imprints, through: :jobs
  has_many :imprint_methods, through: :imprints
  has_many :payments
  has_many :proofs, dependent: :destroy
  has_many :order_quotes, dependent: :destroy
  has_many :quotes, through: :order_quotes
  has_many :quote_requests, through: :quotes
  has_many :shipments, as: :shippable, dependent: :destroy
  has_many :discounts, as: :discountable, dependent: :destroy
  has_many :job_discounts, through: :jobs, source: :discounts, dependent: :destroy
  has_many :admin_proofs, dependent: :destroy
  has_many :costs, as: :costable
  has_many :name_numbers, through: :imprints

  accepts_nested_attributes_for :payments, :jobs, :shipments
  accepts_nested_attributes_for :costs, allow_destroy: true
  accepts_nested_attributes_for :contact

  validates :tax_rate,
            presence: true,
            numericality: { greater_than: 0 }
  validates :invoice_state,
            presence: true,
            inclusion: {
                in: VALID_INVOICE_STATES,
                message: 'is invalid'
            },
            unless: :fba?
  validates :production_state,
            presence: true,
            inclusion: {
                in: VALID_PRODUCTION_STATES,
                message: 'Invalid production state'
            }
  validates :delivery_method,
            presence: true,
            inclusion: {
                in: VALID_DELIVERY_METHODS,
                message: 'is invalid'
            },
            unless: :fba?
  validates :email,
            presence: true,
            email: true,
            unless: :fba?
  # validates :firstname, presence: true, unless: :fba?
  # validates :lastname, presence: true, unless: :fba?
  validates :name, presence: true
  validates :salesperson_id, presence: true
  validates :store, presence: true
  validates :terms, presence: true
  validates :in_hand_by, presence: true
  validates :invoice_reject_reason, presence: true, if: :invoice_rejected?
  validates :fee_description, presence: true, if: :fee_present?

  validate :must_have_salesperson_cost, if: :canceled?
  validate :must_have_artist_cost,      if: :canceled?
  validate :must_have_private_comment,  if: :canceled?

  before_create { self.delivery_method ||= 'Ship to multiple locations' if fba? }
  after_initialize -> (o) { o.production_state = 'pending' if o.respond_to?(:production_state) && o.production_state.blank? }
  after_initialize -> (o) { o.invoice_state = 'pending' if o.respond_to?(:invoice_state) && o.invoice_state.blank? }
  after_initialize :initialize_contact
  after_initialize do
    next unless respond_to?(:customer_key)
    while customer_key.blank? ||
          Order.where(customer_key: customer_key).where.not(id: id).exists?
      self.customer_key = rand(36**6).to_s(36).upcase
    end
  end
  after_initialize do
    next unless %i(subtotal taxable_total discount_total payment_total).all?(&method(:respond_to?))
    self.subtotal ||= 0
    self.taxable_total ||= 0
    self.discount_total ||= 0
    self.payment_total ||= 0
  end

  # subtotal will be changed when a line item price is changed and it calls recalculate_subtotal on the order.
  before_save :recalculate_payment_state
  before_save :recalculate_coupons, if: :subtotal_changed?
  enqueue :create_production_order, :cancel_production_order, queue: 'api'
  after_save :enqueue_create_production_order, if: :ready_for_production?
  after_save :create_invoice_approval_activity, if: :invoice_state_changed?
  after_save :send_in_hand_by_email, if: :in_hand_by_changed?
  before_save :set_all_states_to_canceled!, if: :just_canceled?

  alias_method :comments, :all_comments
  alias_method :comments=, :all_comments=

  paginates_per 20

  default_scope -> { order(created_at: :desc) }
  scope :fba, -> { where(terms: 'Fulfilled by Amazon') }
  scope :with_first_name, -> name { joins(:contact).where(crm_contacts: { first_name: name }) }

  attr_accessor :bad_variant_ids

  state_machine :notification_state, :initial => :pending do

    event :attempted do
      transition :pending => :attempted
      transition :attempted => :attempted
      transition :notified => :attempted
    end

    event :notified do
      transition :pending => :notified
      transition :attempted => :notified
      transition :notified => :notified
    end

    event :picked_up do
      transition :pending => :picked_up
      transition :attempted => :picked_up
      transition :notified => :picked_up
    end

    event :shipped do
      transition any => :shipped
    end

    event :notification_canceled do
      transition any => :notification_canceled
    end
  end

  state_machine :artwork_state, :initial => :pending_artwork_requests do

    ########################
    # Artwork Phase Callbacks
    #########################
    after_transition on: :artwork_complete do |order|
      order.artwork_requests.each{|ar| ar.artwork_added }
    end

    ########################
    # Proof Phase Callbacks
    #########################
    after_transition on: :proofs_ready do |order|
      order.proofs.where(state: 'not_ready').each(&:ready)
    end

    after_transition on: :proofs_manager_approved do |order|
      order.proofs.where(state: 'pending_manager_approval').each(&:manager_approved)
    end

    after_transition on: :emailed_customer_proofs do |order|
      order.proofs.where.not(state: ['manager_rejected', 'customer_rejected']).each(&:emailed_customer)
    end

    after_transition on: :proofs_manager_rejected do |order|
      order.proofs.where.not(state: ['manager_rejected', 'customer_rejected']).each(&:manager_rejected)
    end

    after_transition on: :proofs_customer_approved do |order|
      order.proofs.where(state: 'pending_customer_approval').each(&:customer_approved)
    end

    after_transition on: :proofs_customer_rejected do |order|
      order.proofs.where.not(state: ['manager_rejected', 'customer_rejected']).each(&:customer_rejected)
    end

    ############################
    # Artwork Phase Transitions
    ############################
    event :artwork_requests_complete do
      transition :pending_artwork_requests => :pending_artwork_and_proofs,
                 :unless => lambda{ |x| x.missing_artwork_requests? }
      transition :pending_artwork_requests => :pending_artwork,
                 :unless => lambda{ |x| x.missing_artwork_requests? && !x.missing_proofs? }
    end

    event :artwork_complete do
      transition :pending_artwork => :pending_proofs,
                 :if => lambda{ |x| x.missing_proofs? && !x.missing_assigned_artwork_requests? }
      transition :pending_artwork => :pending_manager_approval,
                 :if => lambda{ |x| !x.missing_proofs? && !x.missing_assigned_artwork_requests? }
      transition :pending_artwork_and_proofs => :pending_proofs,
                 :if => lambda{ |x| x.missing_proofs? && !x.missing_assigned_artwork_requests? }
      transition :pending_artwork_and_proofs => :pending_manager_approval,
                 :if => lambda{ |x| !x.missing_proofs? && !x.missing_assigned_artwork_requests? }
    end

    event :artwork_rejected do
      transition any => :pending_artwork_and_proofs
    end

    ############################
    # Proof Phase Transitions
    ############################
    event :proofs_ready do
      transition :pending_proofs => :pending_manager_approval, :unless => lambda{ |x| x.missing_proofs? }
    end

    event :proofs_manager_approved do
      transition :pending_manager_approval => :pending_proof_submission
    end

    event :proofs_manager_rejected do
      transition any => :pending_proofs
    end

    event :emailed_customer_proofs do
      transition :pending_proof_submission => :pending_customer_approval
    end

    event :proofs_customer_rejected do
      transition any => :pending_proofs
    end

    event :proofs_customer_approved do
      transition :pending_customer_approval => :ready_for_production
    end

    event :put_artwork_into_production do
      transition :ready_for_production => :in_production
    end

    event :artwork_canceled do
      transition any => :artwork_canceled
    end

    event :artwork_not_required do
      transition :pending_artwork_requests => :no_artwork_required
    end

    event :add_artwork_requirement do
      transition :no_artwork_required => :pending_artwork_requests
    end
  end
  
  def send_in_hand_by_email
    return unless production?

    OrderMailer.in_hand_by_changed(self, production_url).deliver_now 
  end

  def check_for_imprints_requiring_artwork!
    if imprint_methods.where(requires_artwork: true).empty?
      artwork_not_required! if can_artwork_not_required?
    else
      add_artwork_requirement! if can_add_artwork_requirement?
    end
  end

  # Use method_missing to catch calls to recalculate_* (for subtotal, tax, etc)
  def respond_to?(method_name)
    if /^re(?<calc_method>calculate_\w+)!?$/ =~ method_name.to_s
      super || super(calc_method)
    else
      super
    end
  end

  def method_missing(method_name, *args, &block)
    if /^recalculate_(?<field_to_recalc>\w+)!?$/ =~ method_name.to_s && respond_to?(field_to_recalc)
      send "#{field_to_recalc}=", send("calculate_#{field_to_recalc}", *args)
      save! if /.*!$/ =~ method_name
    else
      super
    end
  end
  # order.recalculate_tax => { order.tax = order.calculate_tax }

  def recalculate_all
    methods.grep(/^calculate_\w+$/).map do |method_name|
      send "re#{method_name}"
    end
  end
  def recalculate_all!
    recalculate_all
    save!
  end

  def complete?
    payment_state    == 'Payment Terms Met' &&
    invoice_state    == 'approved'          &&
    production_state == 'complete'          &&
    (artwork_state == 'in_production' || artwork_state == 'no_artwork_required')
  end

  def requires_artwork?(force = false)
    if force
      @requires_artwork = nil
      requires_artwork?(false)
    else
      @requires_artwork ||= imprint_methods.where(requires_artwork: true).exists?
    end
  end

  def just_canceled?
    canceled_changed? && canceled? && !canceled_was
  end

  def jobs_attributes=(attrs)
    return super unless fba?

    attrs = (attrs.try(:values) || attrs).map(&:with_indifferent_access)

    # Sort jobs by shipping location
    jobs_by_shipping_location = {}
    attrs.each do |job_attrs|
      shipping_location      = job_attrs[:shipping_location]
      shipping_location_size = job_attrs[:shipping_location_size].to_i

      jobs_by_shipping_location[[shipping_location, shipping_location_size]] ||= []
      jobs_by_shipping_location[[shipping_location, shipping_location_size]] << job_attrs
    end

    # Sort shipping locations by size
    sorted_shipping_locations = jobs_by_shipping_location.keys.sort_by(&:last)

    sorted_jobs = []
    sorted_shipping_locations.each do |key|
      # Sort jobs within each location by total line item quantity
      sorted_jobs += jobs_by_shipping_location[key].sort_by do |job_attrs|
        job_attrs[:line_items_attributes].values.reduce(0) { |n, l| n + l[:quantity].to_i }
      end
    end

    # Add sort order to each job and job name
    sorted_jobs.each_with_index do |job_attrs, index|
      job_attrs[:sort_order] = index
      job_attrs[:name] = "Job #{index + 1} - #{job_attrs[:name]}"

      job_attrs.delete(:shipping_location)
      job_attrs.delete(:shipping_location_size)
    end

    super(sorted_jobs)
  end

  def fee_present?
    !fee.nil? && fee != 0
  end

  def total_cost
    costs.pluck(:amount).compact.reduce(0, :+) +
    line_items.pluck(:cost_amount).compact.reduce(0, :+)
  end

  def id=(new_id)
    return if new_id.blank?
    super
  end

  def bad_variant_ids
    @bad_variant_ids ||= []
  end

  def ready_for_production?
    return if production? || imported_from_admin?

    !canceled? &&
    (payment_status == 'Payment Terms Met' ||
    payment_status == 'Payment Complete' || fba?) &&
    invoice_state  == 'approved'
  end

  def invoice_rejected?
    invoice_state == 'rejected'
  end

  def all_shipments
    jobs.flat_map{|job| job.shipments }.concat(shipments.to_a)
  end

  def all_discounts(reload = false)
    if reload
      discounts.reload + job_discounts.reload
    else
      discounts + job_discounts
    end
  end

  def fba?
    terms == 'Fulfilled by Amazon'
  end

  def balance
    balance_excluding([], [])
  end

  def balance_excluding(exclude_payments = [], exclude_discounts = [])
    balance = total_excluding_discounts(exclude_discounts) - payment_total_excluding(exclude_payments)
    balance.round(2)
  end

  def balance_excluding_discounts(exclude = [])
    balance_excluding([], exclude)
  end

  def get_salesperson_id(id, current_user)
    id ? Order.find(id).salesperson_id : current_user.id
  end

  def get_store_id(id, current_user)
    id ? Order.find(id).store_id : current_user.store_id
  end

  def salesperson_full_name
    salesperson.full_name
  end

  def payment_status
    self.payment_state ||= calculate_payment_state
  end

  def proof_state
    return 'pending_artwork_requests' if missing_artwork_requests?
    return 'pending' if missing_proofs?
    return 'submitted_to_customer' if proofs_pending_approval?
    return 'rejected' if !missing_artwork_requests? && missing_approved_proofs?
    return 'approved' unless missing_approved_proofs?
  end

  def create_contact_from_deprecated_fields!
    if existing_id = Crm::Contact.with_email(deprecated_email).pluck(:id).first
      self.contact_id = existing_id
      return
    end

    if deprecated_email.blank?
      build_contact
      return
    end

    self.contact = Crm::Contact.new(
      first_name: deprecated_firstname,
      last_name:  deprecated_lastname,
      twitter:    deprecated_twitter,

      primary_email_attributes: {
        address: deprecated_email,
        primary: true
      },
      primary_phone_attributes: {
        number:  deprecated_phone_number,
        primary: true
      }
    )
  end

  def contact_attributes=(attrs)
    if id.blank? && attrs['id'].present?
      self.contact_id = attrs['id']
    else
      super
    end
  end

  # ====== Contact delegations =======
  def email
    return deprecated_email if contact.nil?
    contact.primary_email.address
  end

  def firstname
    return deprecated_firstname if contact.nil?
    contact.first_name
  end

  def lastname
    return deprecated_lastname if contact.nil?
    contact.last_name
  end

  def twitter
    return deprecated_twitter if contact.nil?
    contact.twitter
  end

  def phone_number
    return deprecated_phone_number if contact.nil?
    contact.primary_phone.number
  end
  # ====== End of contact delegations =======

  def full_name
    "#{firstname} #{lastname}"
  end

  def full_name_changed?
    if contact.nil?
      firstname_changed? || lastname_changed?
    else
      contact.first_name_changed? || contact.last_name_changed?
    end
  end

  def calculate_payment_state
    if balance <= 0
      'Payment Complete'
    else
      self.in_hand_by ||= Time.now
      case terms
      when 'Paid in full on purchase'
        'Awaiting Payment'
      when 'Half down on purchase'
        balance >= (total * 0.51) ? 'Awaiting Payment' : 'Payment Terms Met'
      when 'Paid in full on pick up'
        Time.now >= self.in_hand_by ? 'Awaiting Payment' : 'Payment Terms Met'
      when 'Net 30'
        Time.now >= (self.in_hand_by + 30.days) ? 'Awaiting Payment' : 'Payment Terms Met'
      when 'Net 60'
        Time.now >= (self.in_hand_by + 60.days) ? 'Awaiting Payment' : 'Payment Terms Met'
      else 'Payment Terms Pending'
      end
    end
  end

  def bad_payments_filter(exclude = [])
    proc do |p|
      next true if p.nil? || p.amount.nil?
      next true if exclude.include?(p.id) || exclude.include?(p)
      next true if p.totally_refunded?
      false
    end
  end

  def sales_tax_balance
    tax - payments.reload.reject(&bad_payments_filter).map(&:sales_tax_amount).compact.reduce(0, :+)
  end

  def calculate_payment_total(exclude = [])
    exclude = Array(exclude)

    payments.reload.reject(&bad_payments_filter(exclude)).reduce(0) do |total, p|
      total + p.amount - p.refunded_amount
    end
  end

  def payment_total_excluding(exclude = [])
    return payment_total if Array(exclude).empty?
    calculate_payment_total(exclude)
  end

  def percent_paid
    percent_paid_excluding([])
  end

  def percent_paid_excluding(exclude = [])
    payment_total_excluding(exclude) / total * 100
  end

  def salesperson_name
    salesperson.full_name
  end

  def discount_total(exclude = [])
    return 0 if exclude == :all
    exclude.empty? ? super() : calculate_discount_total(exclude)
  end

  def calculate_discount_total(exclude = [])
    all_discounts(:reload)
      .reject { |d| exclude.include?(d) || exclude.include?(d.try(:id)) }
      .map { |d| d.amount.to_f }.reduce(0, :+)
  end

  def calculate_subtotal
    line_items.reload.map { |li| li.total_price.to_f }.reduce(0, :+)
  end

  def tax(exclude_discounts = [])
    return 0 if tax_exempt?
    return 0 if discount_total >= taxable_total

    ((taxable_total - discount_total(exclude_discounts)) * tax_rate).round(2)
  end
  alias_method :tax_excluding_discounts, :tax

  def calculate_taxable_total
    return 0 if tax_exempt?
    line_items.reload.taxable.map { |li| li.total_price.to_f }.reduce(0, :+)
  end

  def tax_rate
    super || (self.tax_rate = Setting.default_sales_tax_rate || 0.06)
  end

  def tax_rate_percent
    tax_rate * 100
  end

  def tax_rate_percent=(value)
    self.tax_rate = value.to_f / 100
  end

  def fee_percent
    return 0 if fee.nil?
    fee * 100
  end

  def fee_percent=(value)
    self.fee = value.to_f / 100
  end

  def total_fee
    subtotal * (fee || 0)
  end

  def total(exclude_discounts = [])
    t = subtotal + total_fee + tax_excluding_discounts(exclude_discounts) + shipping_price
    if exclude_discounts == :all
      return t
    else
      t - discount_total(exclude_discounts)
    end
  end
  alias_method :total_excluding_discounts, :total

  def recalculate_coupons
    new_instance_order = self
    discounts.reload.coupon.each do |discount|
      discount.define_singleton_method(:discountable) { new_instance_order }
      discount.update_column :amount, discount.calculate_amount
    end

    jobs.reload.each do |job|
      job.define_singleton_method(:jobbable) { new_instance_order }
      new_instance_job = job

      job.discounts.coupon.each do |discount|
        discount.define_singleton_method(:discountable) { new_instance_job }
        discount.update_column :amount, discount.calculate_amount
      end
    end

    recalculate_discount_total
  end

  def duplicate!(new_salesperson = nil)
    new_order = dup
    case new_salesperson
    when Fixnum, String then new_order.salesperson_id = new_salesperson
    when nil # do nothing
    else new_order.salesperson = new_salesperson
    end
    new_order.name             = "#{name} - Clone"
    new_order.in_hand_by       = 1.week.from_now
    new_order.softwear_prod_id = nil
    new_order.invoice_state    = 'pending'
    new_order.production_state = 'pending'
    new_order.artwork_state = 'pending_manager_approval'
    new_order.notification_state = 'pending'
    new_order.imported_from_admin = false

    new_order.save!(validate: false)

    jobs.each do |job|
      new_job = job.dup
      new_job.jobbable = new_order
      new_job.softwear_prod_id = nil

      new_job.save!(validate: false)
      new_job.imprints.destroy_all if new_order.fba?

      job.imprints.each do |imprint|
        new_imprint = imprint.dup
        new_imprint.softwear_prod_id = nil
        new_imprint.job_id = new_job.id

        new_imprint.save!(validate: false)

        unless imported_from_admin?
          imprint.artwork_requests.each do |artwork_request|
            new_artwork_request = artwork_request.dup
            new_artwork_request.ink_color_ids = artwork_request.ink_color_ids.dup
            new_artwork_request.salesperson = new_order.salesperson
            new_artwork_request.imprints = [new_imprint]
            new_artwork_request.state = 'unassigned'
            new_artwork_request.softwear_prod_id = nil
            new_artwork_request.save
            new_artwork_request.save!(validate: false)
            new_artwork_request.artworks = artwork_request.artworks
          end
        end
      end

      job.line_items.each do |line_item|
        new_line_item = line_item.dup
        new_line_item.job_id = new_job.id

        new_line_item.save!(validate: false)
      end

    end

    new_order.reload.recalculate_all!
    new_order.reload

  rescue ActiveRecord::RecordInvalid => _
    new_order.destroy_recursively if new_order.persisted?
    raise
  end

  def name_and_numbers
    name_numbers.joins(:brand).joins(:size).order('brands.name, sizes.sort_order')
  end

  def create_production_order(options = {})
    return if canceled?

    if options[:force] == false && !softwear_prod_id.nil?
      raise "Attempted to create a duplicate production order."
    end

    # NOTE make sure the permitted params in Production match up with this
    prod_order_attributes = {
      softwear_crm_id:    id,
      deadline:           in_hand_by,
      name:               name,
      customer_name:      full_name,
      fba:                fba?,
      has_imprint_groups: false,

      jobs_attributes: production_jobs_attributes
    }

    prod_order = Production::Order.where(softwear_crm_id: id).first

    if prod_order.blank?
      prod_order = Production::Order.post_raw(prod_order_attributes)
    else
      if options[:force]
        prod_order.jobs.each(&:destroy)
        prod_order.update_attributes(prod_order_attributes)
      end
    end

    update_column :softwear_prod_id, prod_order.id
    update_column :production_state, :in_production unless prod_order.id.nil?

    if prod_order.errors.any?
      raise "The exported Production order ended up invalid. Contact devteam about this.\n\n"\
            "=== Errors: ===\n#{prod_order.errors.full_messages.join("\n")}\n\n"\
            "=== Attributes: ===\n#{JSON.pretty_generate(prod_order.attributes)}"
    end

    # These hashes are used to minimize time spend looping and updating softwear_prod_id's
    job_hash = {}
    imprint_hash = {}

    prod_order.jobs.each do |p_job|
      if p_job.softwear_crm_id.nil?
        raise "A production job was not assigned its crm id. "\
              "Contact devteam about this.\n"\
              "Here are its errors (if any): #{p_job.errors.full_messages}\n\n"\
              "Here are its attributes: #{JSON.pretty_generate(p_job.attributes)}"
      else
        job_hash[p_job.softwear_crm_id] = p_job
      end

      p_job.imprints.each do |p_imprint|
        next unless p_imprint.respond_to?(:softwear_crm_id)

        imprint_hash[p_imprint.softwear_crm_id] = p_imprint
      end
    end

    missing_id = lambda do |ident, id|
      issue_warning(
        "Order#create_production_order", "#{ident} ##{id} is missing a production entry"
      )
      nil
    end

    jobs.each do |job|
      job.update_column :softwear_prod_id, job_hash[job.id].try(:id) || missing_id['Job', job.id]

      job.imprints.each do |imprint|
        imprint.update_column :softwear_prod_id, imprint_hash[imprint.id].try(:id) || missing_id['Imprint', imprint.id]
      end
    end

    artwork_requests.uniq(&:id).each do |artwork_request|
      artwork_request.create_trains
      artwork_request.create_imprint_group_if_needed
    end

    all_shipments.each(&:create_train) unless fba?

    case delivery_method
    when 'Pick up in Ann Arbor'
      Production::StageForPickupTrain.create(order_id: softwear_prod_id)
    when 'Pick up in Ypsilanti'
      Production::StoreDeliveryTrain.create(order_id: softwear_prod_id)
    else
    end
  end

  warn_on_failure_of :create_production_order unless Rails.env.test?

  def create_invoice_approval_activity
    if invoice_state_changed?(from: 'pending', to: 'approved')
      create_activity key: 'order.approved_invoice'
    end
  end

  def name_in_production
    "#{full_name} - #{name}"
  end

  def name_in_production_changed?
    name_changed? || full_name_changed?
  end

  def sync_with_production(sync)
    sync[name:          :name_in_production]
    sync[deadline:      :in_hand_by]
    sync[customer_name: :full_name]
  end

  def production_jobs_attributes
    attrs = {}

    jobs.each_with_index do |job, index|
      # NOTE make sure the permitted params in Production match up with this
      attrs[index] = job.production_attributes
      attrs[index].delete_if { |_,v| v.nil? }
    end

    attrs
  end

  # TODO don't need this
  def generate_jobs(fba_job_infos)
    fba_job_infos.map(&:with_indifferent_access).each do |fba|
      fba[:jobs].each do |style, job_info|
        job = jobs.create(name: "#{fba[:job_name]} - #{style}")

        if !job_info.nil?
          job_info.each do |imprintable, color, quantities|
            LineItem.create_imprintables(
              job,
              imprintable,
              color,
              quantity: quantities
            )
          end
        end
      end
    end
  end

  def freshdesk_proof_ticket_link(obj = nil)
    obj ||= self
    return if obj.try(:freshdesk_proof_ticket_id).blank?
    "http://annarbortees.freshdesk.com/helpdesk/tickets/#{freshdesk_proof_ticket_id}"
  end

  def invoice_should_be_approved_by_now?
    in_hand_by <= 6.business_days.from_now
  end

  def missing_artwork_requests?
    imprints.map{|i| i.artwork_requests.empty? }.include?(true) ||
      artwork_requests.map(&:state).include?('artwork_request_rejected')
  end

  def missing_assigned_artwork_requests?
    artwork_requests.map(&:state).include?('unassigned')
  end

  def missing_proofs?
    artwork_requests.map{|ar| ar.proofs.where.not(state: ['customer_rejected', 'manager_rejected']).empty? }.include? true
  end

  def missing_approved_proofs?
    artwork_requests.map{|ar| ar.has_approved_proof? }.include? false
  end

  def proofs_pending_approval?
    artwork_requests.map{|ar| ar.has_proof_pending_approval? }.include? true
  end


  def warnings_count
    warnings.active.count
  end

  def format_phone_for_contact
    num = phone_number
    return "000-000-0000" if(num.nil? || num.blank?)

    num.gsub!(/\D/, '')

    if num.length == 11 && num[0] == '1'
      num
    elsif num.length == 10
      num = '1' + num
    elsif num.length >= 7 && num.length <= 9
      dif = num.length - 7
      if dif != 0
        num = num.slice(dif, 7)
      end
      num = '1734' + num
    end

    "#{num.slice(1, 3)}-#{num.slice(4, 3)}-#{num.slice(7, 4)}"
  end

  def prod_api_confirm_job_counts
    return if complete? || canceled?

    if jobs.count != production.jobs.count
      message = "API Job counts don't match for CRM(#{id})=#{jobs.count} PRODUCTION(#{softwear_prod_id})=#{production.jobs.count}"
      logger.error message

      warnings << Warning.new(
        source: 'API Production Configuration Report',
         message: message
      )

      Sunspot.index(self)
    end
  end

  def prod_api_confirm_shipment
    return if complete? || canceled?

    case delivery_method
    when 'Pick up in Ann Arbor'
      unless production.post_production_trains.map(&:train_class).include?("stage_for_pickup_train")
        message = "API Order StageForPickupTrain missing PRODUCTION(#{softwear_prod_id}) CRM(#{id})"
        logger.error message

        warnings << Warning.new(
          source: 'API Production Configuration Report',
           message: message
        )
      end
    when 'Pick up in Ypsilanti'
      unless production.post_production_trains.map(&:train_class).include?("store_delivery_train")
        message = "API Order StoreDeliveryTrain missing PRODUCTION(#{softwear_prod_id}) CRM(#{id})"
        logger.error message

        warnings << Warning.new(
          source: 'API Production Configuration Report',
           message: message
        )
      end
    when 'Ship to one location'
      if shipments.empty?
        message =  "API Can't confirm shipment configured correctly without shipments being created"
        logger.error message

        self.warnings << Warning.new(
          source: 'API Production Configuration Report',
          message: message
        )
      else
        shipments.each do |shipment|
          if shipment.shipping_method.name == 'Ann Arbor Tees Delivery'
            if !production.post_production_trains.map(&:train_class).include?("local_delivery_train")
              message = "API Order LocalDeliveryTrain missing PRODUCTION(#{softwear_prod_id}) CRM(#{id})"
              logger.error message

              warnings << Warning.new(
                source: 'API Production Configuration Report',
                 message: message
              )
            end
          else
            if !production.post_production_trains.map(&:train_class).include?("shipment_train")
              message = "API Order ShipmentTrain missing PRODUCTION(#{softwear_prod_id}) CRM(#{id})"
              logger.error message

              warnings << Warning.new(
                source: 'API Production Configuration Report',
                 message: message
              )
            end
          end
        end
      end
    when 'Ship to multiple locations'
      message =  "CRM Production isn't capable of multiple shipment location"
      logger.error message

      self.warnings << Warning.new(
        source: 'API Production Configuration Report',
        message: message
      )
    end
    Sunspot.index(self)
  end

  def prod_api_confirm_artwork_preprod
    return if complete? || canceled?

    unless screen_print_artwork_requests.empty?
      screen_train_count = production.pre_production_trains.map(&:train_class).delete_if{|x| x != 'screen_train' }.count
      unless screen_train_count == screen_print_artwork_requests.count
        message = "API Order ScreenTrain counts are off CRM(#{id}} has #{screen_print_artwork_requests.count} screen print requests"\
          ", PRODUCTION(#{softwear_prod_id}) has #{screen_train_count} screen_trains"
        logger.error message

        warnings << Warning.new(
          source: 'API Production Configuration Report',
           message: message
        )
      end
    end

    unless dtg_artwork_requests.empty?
      ar3_train_count = production.pre_production_trains.map(&:train_class).delete_if{|x| x != 'ar3_train' }.count
      unless ar3_train_count == dtg_artwork_requests.count
        message = "API Order Ar3Train counts are off CRM(#{id}} has #{dtg_artwork_requests.count} dtg requests"\
          ", PRODUCTION(#{softwear_prod_id}) has #{ar3_train_count} ar3_trains"
        logger.error message

        warnings << Warning.new(
          source: 'API Production Configuration Report',
           message: message
        )
      end
    end

    unless embroidery_artwork_requests.empty?
      digitization_train_count = production.pre_production_trains.map(&:train_class).delete_if{|x| x != 'digitization_train' }.count
      unless digitization_train_count == embroidery_artwork_requests.count
        message = "API Order DigitizationTrain counts are off CRM(#{id}} has #{embroidery_artwork_requests.count} digitization requests"\
          ", PRODUCTION(#{softwear_prod_id}) has #{digitization_train_count} digitization_trains"
        logger.error message

        warnings << Warning.new(
          source: 'API Production Configuration Report',
           message: message
        )
      end
    end

    Sunspot.index(self)
  end

  def dtg_artwork_requests
    artwork_requests.to_a.delete_if{|x| !['Digital Print - Non-White (DTG-NW)', 'Digital Print - White (DTG-W)'].include? x.imprint_method.name}
  end

  def screen_print_artwork_requests
    artwork_requests.to_a.delete_if{|x| !['Screen Print', 'Large Format Screen Print'].include? x.imprint_method.name}
  end

  def embroidery_artwork_requests
    artwork_requests.to_a.delete_if{|x| !['In-House Embroidery', 'Outsourced Embroidery', 'In-House Applique EMB'].include? x.imprint_method.name}
  end

  def check_if_shipped!
    return unless delivery_method && delivery_method.include?('Ship')
    return if notification_state == 'shipped'
    jobs.reload; shipments.reload
    return if all_shipments.empty?

    if all_shipments.all?(&:shipped?)
      shipped
      save!
    end
  end

  def setup_art_for_fba
    jobs_by_template = {}

    missing_artworks = false
    missing_proofs = false

    jobs.includes(:imprints).each do |job|
      jobs_by_template[job.fba_job_template_id] ||= []
      jobs_by_template[job.fba_job_template_id] << job
    end

    jobs_by_template.each do |job_template_id, jobs|
      fba_job_template = FbaJobTemplate.find(job_template_id)
      artworks = fba_job_template.artworks.compact
      artworks = [Artwork.fba_missing] if artworks.blank?

      fba_job_template.fba_imprint_templates.each do |fba_imprint_template|
        artwork_request = ArtworkRequest.create
        artwork_request.description = "Generated for FBA"
        artwork_request.deadline    = in_hand_by
        artwork_request.state       = :manager_approved
        artwork_request.salesperson = salesperson
        artwork_request.approved_by = salesperson
        artwork_request.artwork_ids = [fba_imprint_template.artwork_id].compact
        artwork_request.priority    = 5
        artwork_request.imprint_ids = Imprint.where(
          job_id: jobs.map(&:id), print_location_id: fba_imprint_template.print_location_id
        )
          .pluck(:id)

        if artwork_request.artwork_ids.blank?
          missing_artworks = true
          artwork_request.artwork_ids = [Artwork.fba_missing.try(:id)]
        end

        unless artwork_request.save
          issue_warning('FBA Order Generation', "Unable to save artwork request: #{artwork_request.errors.full_messages.join(', ')}")
        end
      end

      if fba_job_template.mockup
        mockup_attributes = {
          file:        fba_job_template.mockup.file,
          description: fba_job_template.mockup.description
        }
      else
        mockup_attributes = nil
        missing_proofs = true
      end

      proof = Proof.create(
        order_id:   id,
        job_id:     jobs.first.id,
        approve_by: in_hand_by,
        state:      :customer_approved,

        mockups_attributes: [mockup_attributes].compact,
        artworks: artworks
      )

      unless proof.persisted?
        issue_warning('FBA Order Generation', "Unable to save proof: #{proof.errors.full_messages.join(', ')}")
      end
    end

    if missing_artworks
      if missing_proofs
        update_column :artwork_state, 'pending_artwork_and_proofs'
      else
        update_column :artwork_state, 'pending_artwork_requests'
      end
    elsif missing_proofs
      update_column :artwork_state, 'pending_proofs'
    else
      update_column :artwork_state, 'in_production'
    end
  end
  warn_on_failure_of :setup_art_for_fba

  def tib_query
    fields = %w(
      li.id li.quantity b.name c.name s.display_value
    )
      .map
      .with_index { |f, i| [f, i] }
      .to_h

    <<-SQL
      select #{fields.keys.join(', ')} from line_items li

      join jobs                 j  on (j.id = li.job_id and j.jobbable_type = 'Order')
      join imprintable_variants iv on (iv.id = li.imprintable_object_id)
      join colors               c  on (c.id = iv.color_id)
      join sizes                s  on (s.id = iv.size_id)
      join imprintables         i  on (i.id = iv.imprintable_id)
      join brands               b  on (b.id = i.brand_id)

      and li.imprintable_object_type = "ImprintableVariant"
      and j.deleted_at is not null
      and li.deleted_at is not null

      order by i.id, c.id, s.sort_order
    SQL
  end

  def total_imprintable_breakdown
    fields = %w(
      li.id li.quantity b.name c.name s.display_value
    )
      .map
      .with_index { |f, i| [f, i] }
      .to_h

    sql_results = ActiveRecord::Base.connection.execute <<-SQL
      select #{fields.keys.join(', ')} from line_items li

      join jobs                 j  on (j.id = li.job_id and j.jobbable_type = 'Order')
      join orders               o  on (o.id = j.jobbable_id)
      join imprintable_variants iv on (iv.id = li.imprintable_object_id)
      join colors               c  on (c.id = iv.color_id)
      join sizes                s  on (s.id = iv.size_id)
      join imprintables         i  on (i.id = iv.imprintable_id)
      join brands               b  on (b.id = i.brand_id)

      where o.id = #{id}
      and li.imprintable_object_type = "ImprintableVariant"
      and o.deleted_at is not null
      and j.deleted_at is not null
      and li.deleted_at is not null

      order by o.id, i.id, c.id, s.sort_order
    SQL

    all_line_items = sql_results.map do |r|
      OpenStruct.new(
        id:             r[fields['li.id']],
        quantity:       r[fields['li.quantity']],
        brand_name:     r[fields['b.name']],
        color_name:     r[fields['c.name']],
        size_display:   r[fields['s.display_value']]
      )
    end

    by_imprintable = all_line_items.group_by(&:brand_name)
    by_imprintable.each do |brand_name, line_items|
      by_imprintable[brand_name] = line_items.group_by(&:color_name)
    end
    by_imprintable
  end

  def destroy_recursively
    nuke = nil
    nuke = lambda do |object|
      associations_to_destroy = object.class.reflect_on_all_associations
        .select { |a| a.options[:dependent] == :destroy }

      associations_to_destroy.each do |assoc|
        if assoc.is_a?(ActiveRecord::Reflection::HasManyReflection) ||
           assoc.is_a?(ActiveRecord::Reflection::ThroughReflection)
          object.send(assoc.name).each(&nuke)
        else
          nuke.(object.send(assoc.name))
        end
      end

      if object.paranoid?
        object.update_column :deleted_at, Time.now
      else
        object.destroy
      end
    end

    nuke.(self)
    Sunspot.index self
  end

  def initialize_contact
    return unless contact.nil?

    if fba?
      if fba_contact = Crm::Contact.joins(:primary_email).where(crm_emails: { address: FBA_CONTACT_EMAIL }).first
        self.contact = fba_contact
      else
        self.contact = Crm::Contact.new(
          first_name: 'Fulfilled by',
          last_name: 'Amazon',
          primary_email_attributes: {
            address: FBA_CONTACT_EMAIL
          },
          primary_phone_attributes: {
            number: '000-000-0000'
          }
        )
      end
    else
      create_contact_from_deprecated_fields!
    end
  end

  def set_all_states_to_canceled!
    update_column :artwork_state, 'artwork_canceled'
    update_column :notification_state, 'notification_canceled'
    update_column :invoice_state, 'canceled'
    update_column :production_state, 'canceled'
    update_column :payment_state, 'Canceled'
    enqueue_cancel_production_order if production?

    quotes.each do |q|
      q.update_column :state, 'lost'
    end
  end

  def cancel_production_order
    return unless production?

    production.canceled = true
    production.save!
  end
  warn_on_failure_of :cancel_production_order

  # == Cancelation requirements: ==

  def must_have_salesperson_cost
    unless costs.where(type: 'Salesperson').exists?
      errors.add(:cancelation, "A salesperson cost must be filled out.")
    end
  end

  def must_have_artist_cost
    return if artwork_requests.empty?

    unless costs.where(type: 'Artist').exists?
      errors.add(:cancelation, "An artist cost must be filled out.")
    end
  end

  def must_have_private_comment
    unless private_comments.exists?
      errors.add(
        :cancelation,
        "The order must have at least one private comment."
      )
    end
  end
end
