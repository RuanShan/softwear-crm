class Order < ActiveRecord::Base
  include TrackingHelpers
  include ProductionCounterpart

  acts_as_paranoid
  acts_as_commentable :public, :private
  acts_as_warnable

  is_activity_recipient

  searchable do
    text :name, :email, :firstname, :lastname, :invoice_state,
         :company, :twitter, :terms, :delivery_method, :salesperson_full_name

    text :jobs do
      jobs.map { |j| "#{j.name} #{j.description}" }
    end

    [
      :firstname, :lastname, :email, :terms,
      :delivery_method, :company, :phone_number,
      :payment_status, :invoice_state, :production_state,
      :notification_state, :salesperson_full_name
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
    'approved'
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

  belongs_to :salesperson, class_name: User
  belongs_to :store
  has_many :jobs, as: :jobbable, dependent: :destroy
  has_many :artwork_requests, through: :jobs, dependent: :destroy
  has_many :imprints, through: :jobs
  has_many :payments
  has_many :proofs, dependent: :destroy
  has_many :order_quotes, dependent: :destroy
  has_many :quotes, through: :order_quotes
  has_many :quote_requests, through: :quotes
  has_many :shipments, as: :shippable, dependent: :destroy
  has_many :discounts, as: :discountable, dependent: :destroy
  has_many :job_discounts, through: :jobs, source: :discounts, dependent: :destroy

  accepts_nested_attributes_for :payments, :jobs

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

  after_initialize -> (o) { o.production_state = 'pending' if o.production_state.blank? }
  after_initialize -> (o) { o.invoice_state = 'pending' if o.invoice_state.blank? }
  after_save :enqueue_create_production_order, if: :ready_for_production?

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

  def all_shipments
    jobs.map{|job| job.shipments }.concat(shipments.to_a).flatten
  end

  def all_discounts
    discounts + job_discounts
  end

  def fba?
    terms == 'Fulfilled by Amazon'
  end

  def balance
    balance = total - payment_total
    balance.round(2)
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

  def line_items
    LineItem.where(line_itemable_id: job_ids, line_itemable_type: 'Job')
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

  def full_name
    "#{firstname} #{lastname}"
  end

  def payment_total
    payments.reduce(0) do |total, p|
      p && !p.is_refunded? ? total + p.amount : total
    end
  end

  def percent_paid
    payment_total / total * 100
  end

  def salesperson_name
    User.find(salesperson_id).full_name
  end

  def discount_total
    all_discounts.map { |d| d.amount.to_f }.reduce(0, :+)
  end

  def subtotal
    line_items.map(&:total_price).map(&:to_f).reduce(0, :+)
  end

  def tax
    return 0 if tax_exempt?
    (
      line_items.where(taxable: true).map(&:total_price).map(&:to_f).reduce(0, :+) - discount_total
    ) * tax_rate
  end

  def tax_rate
    0.06
  end

  def total
    subtotal + tax + shipping_price - discount_total
  end

  def name_number_csv
    csv = name_and_numbers.map{|x| [x.imprint.job.name, x.imprint.number_format, x.imprint.name_format, x.number, x.name ]}
    CSV.from_arrays csv, headers: ["Job", "Number Format", "Name Format", "Number", "Name"], write_headers: true
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

  def sync_with_production(sync)
    sync[:name]
    sync[deadline: :in_hand_by]
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
    imprints.map{|i| i.artwork_requests.empty? }.include? true
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

  private

end
