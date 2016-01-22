class Order < ActiveRecord::Base
  include TrackingHelpers
  include ProductionCounterpart

  acts_as_paranoid
  acts_as_commentable :public, :private
  acts_as_warnable

  is_activity_recipient

  searchable do
    text :name, :email, :firstname, :lastname, :invoice_state, :proof_state, :artwork_state,
         :company, :twitter, :terms, :delivery_method, :salesperson_full_name, :customer_key

    text :jobs do
      jobs.map { |j| "#{j.name} #{j.description}" }
    end

    [
      :firstname, :lastname, :email, :terms,
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

    date :in_hand_by

    reference :salesperson
  end

  tracked by_current_user

  ID_FIELD_TEXT = "DO NOT ENTER ANYTHING INTO THIS FIELD UNLESS YOU'RE KARSTEN"

  VALID_INVOICE_STATES = [
    'pending',
    'approved',
    'rejected'
  ]

  VALID_PRODUCTION_STATES = %w(
    pending in_production complete
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
    'Payment Terms Pending'
  ]

  VALID_PROOF_STATES = [
    :pending_artwork_requests,
    :pending,
    :submitted_to_customer,
    :rejected,
    :approved
  ]


  belongs_to :salesperson, class_name: User
  belongs_to :store
  has_many :jobs, as: :jobbable, dependent: :destroy, inverse_of: :jobbable
  has_many :line_items, through: :jobs, source: :line_items
  has_many :artwork_requests, through: :jobs, dependent: :destroy
  has_many :artworks, through: :artwork_requests
  has_many :imprints, through: :jobs
  has_many :payments
  has_many :proofs, dependent: :destroy
  has_many :order_quotes, dependent: :destroy
  has_many :quotes, through: :order_quotes
  has_many :quote_requests, through: :quotes
  has_many :shipments, as: :shippable, dependent: :destroy
  has_many :discounts, as: :discountable, dependent: :destroy
  has_many :job_discounts, through: :jobs, source: :discounts, dependent: :destroy
  has_many :admin_proofs, dependent: :destroy

  accepts_nested_attributes_for :payments, :jobs, :shipments

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
  validates :firstname, presence: true, unless: :fba?
  validates :lastname, presence: true, unless: :fba?
  validates :name, presence: true
  validates :phone_number,
            format: {
              with: /\d{3}-\d{3}-\d{4}/,
              message: 'is incorrectly formatted, use 000-000-0000'
            },
            unless: :fba?
  validates :salesperson, presence: true
  validates :store, presence: true
  validates :terms, presence: true
  validates :in_hand_by, presence: true
  validates :invoice_reject_reason, presence: true, if: :invoice_rejected?

  before_create { self.delivery_method ||= 'Ship to multiple locations' if fba? }
  after_initialize -> (o) { o.production_state = 'pending' if o.production_state.blank? }
  after_initialize -> (o) { o.invoice_state = 'pending' if o.invoice_state.blank? }
  after_initialize do
    while customer_key.blank? ||
          Order.where(customer_key: customer_key).where.not(id: id).exists?
      self.customer_key = rand(36**6).to_s(36).upcase
    end
  end
  after_initialize do
    self.subtotal ||= 0
    self.taxable_total ||= 0
    self.discount_total ||= 0
    self.payment_total ||= 0
  end

  # subtotal will be changed when a line item price is changed and it calls recalculate_subtotal on the order.
  before_save :recalculate_coupons, if: :subtotal_changed?
  after_save :enqueue_create_production_order, if: :ready_for_production?
  after_save :create_invoice_approval_activity, if: :invoice_state_changed?

  alias_method :comments, :all_comments
  alias_method :comments=, :all_comments=

  paginates_per 20

  default_scope -> { order(created_at: :desc) }
  scope :fba, -> { where(terms: 'Fulfilled by Amazon') }

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

  def jobs_attributes=(attrs)
    return super unless fba?

    attrs = (attrs.try(:values) || attrs).map(&:with_indifferent_access)

    # Sort jobs by shipping location
    jobs_by_shipping_location = {}
    attrs.each do |job_attrs|
      shipping_location      = job_attrs[:shipping_location]
      shipping_location_size = job_attrs[:shipping_location_size]

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

  def id=(new_id)
    return if new_id.blank?
    super
  end

  def bad_variant_ids
    @bad_variant_ids ||= []
  end

  def ready_for_production?
    return if production?

    (payment_status == 'Payment Terms Met' ||
    payment_status == 'Payment Complete') and
    invoice_state  == 'approved'
  end

  def invoice_rejected?
    invoice_state == 'rejected'
  end

  def all_shipments
    jobs.map{|job| job.shipments }.concat(shipments.to_a).flatten
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

  def proof_state
    return 'pending_artwork_requests' if missing_artwork_requests?
    return 'pending' if missing_proofs?
    return 'submitted_to_customer' if proofs_pending_approval?
    return 'rejected' if !missing_artwork_requests? && missing_approved_proofs?
    return 'approved' unless missing_approved_proofs?
  end

  def full_name
    "#{firstname} #{lastname}"
  end

  def full_name_changed?
    firstname_changed? || lastname_changed?
  end

  def calculate_payment_total(exclude = [])
    exclude = Array(exclude)

    payments.reload.reduce(0) do |total, p|
      next total if p.nil? || p.amount.nil?
      next total if exclude.include?(p.id) || exclude.include?(p)
      next total if p.totally_refunded?

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
    User.find(salesperson_id).full_name
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

    (taxable_total - discount_total(exclude_discounts)) * tax_rate
  end
  alias_method :tax_excluding_discounts, :tax

  def calculate_taxable_total
    return 0 if tax_exempt?
    line_items.reload.taxable.map { |li| li.total_price.to_f }.reduce(0, :+)
  end

  def tax_rate
    0.06
  end

  def total(exclude_discounts = [])
    t = subtotal + tax_excluding_discounts(exclude_discounts) + shipping_price
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

  def name_and_numbers
    jobs.map{|j|  j.name_number_imprints
      .flat_map{ |i| i.name_numbers } }
      .flatten
      .sort { |x, y| x.imprint_id <=> y.imprint_id }
  end

  def create_production_order(options = {})
    if options[:force] == false && !softwear_prod_id.nil?
      raise "Attempted to create a duplicate production order."
    end

    # NOTE make sure the permitted params in Production match up with this
    prod_order = Production::Order.post_raw(
      softwear_crm_id:    id,
      deadline:           in_hand_by,
      name:               name,
      customer_name:      full_name,
      fba:                fba?,
      has_imprint_groups: false,

      jobs_attributes: production_jobs_attributes
    )

    update_column :softwear_prod_id, prod_order.id
    update_column :production_state, :in_production

    # These hashes are used to minimize time spend looping and updating softwear_prod_id's
    job_hash = {}
    imprint_hash = {}

    prod_order.jobs.each do |p_job|
      job_hash[p_job.softwear_crm_id] = p_job

      p_job.imprints.each do |p_imprint|
        next unless p_imprint.respond_to?(:softwear_crm_id)

        imprint_hash[p_imprint.softwear_crm_id] = p_imprint
      end
    end

    jobs.each do |job|
      job.update_column :softwear_prod_id, job_hash[job.id].id

      job.imprints.each do |imprint|
        imprint.update_column :softwear_prod_id, imprint_hash[imprint.id].id
      end

      job.artwork_requests.each(&job.method(:create_trains_from_artwork_request))
    end
  end

  warn_on_failure_of :create_production_order unless Rails.env.test?

  if Rails.env.production?
    def enqueue_create_production_order(*args)
      delay(queue: 'api').create_production_order(*args)
    end
  else
    alias_method :enqueue_create_production_order, :create_production_order
  end

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
      attrs[index] = {
        name: job.name,
        softwear_crm_id: job.id,
        imprints_attributes: job.production_imprints_attributes,
        imprintable_train_attributes: job.imprintable_train_attributes
      }
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

  def prod_api_confirm_job_counts
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
end
