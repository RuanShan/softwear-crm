class Order < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  acts_as_commentable :public, :private
  acts_as_warnable

  is_activity_recipient

  searchable do
    text :name, :email, :firstname, :lastname, :invoice_state, 
         :company, :twitter, :terms, :delivery_method

    text :jobs do
      jobs.map { |j| "#{j.name} #{j.description}" }
    end

    [
      :firstname, :lastname, :email, :terms,
      :delivery_method, :company, :phone_number,
      :payment_status, :invoice_state
    ]
      .each { |f| string f }

    double :total
    double :commission_amount

    date :in_hand_by

    reference :salesperson
  end

  tracked by_current_user

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
  has_many :jobs, as: :jobbable
  has_many :artwork_requests, through: :jobs
  has_many :imprints, through: :jobs
  has_many :payments
  has_many :proofs
  has_many :order_quotes
  has_many :quotes, through: :order_quotes
  has_many :quote_requests, through: :quotes
  has_many :shipments, as: :shippable
  has_many :discounts, as: :discountable
  has_many :job_discounts, through: :jobs, source: :discounts

  accepts_nested_attributes_for :payments

  validates :invoice_state,
            presence: true,
            inclusion: {
                in: VALID_INVOICE_STATES,
                message: 'Invalid invoice state'
            }
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
                message: 'Invalid delivery method'
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

  alias_method :comments, :all_comments
  alias_method :comments=, :all_comments=

  default_scope -> { order(created_at: :desc) }
  scope :fba, -> { where(terms: 'Fulfilled by Amazon') }

  def production_order
    Production::Order.where(softwear_crm_id: self.id).first
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
    csv = imprints
      .with_name_number
      .map { |i| [i.name_number.number, i.name_number.name] }

    CSV.from_arrays csv, headers: %w(Number Name), write_headers: true
  end

  def name_and_numbers
    jobs.map{|j|  j.name_number_imprints.flat_map{ |i| i.name_numbers } }.flatten
  end

  def generate_jobs(job_attributes)
    job_attributes.each do |attributes|
      attributes = HashWithIndifferentAccess.new(attributes)

      job = jobs.create(name: attributes[:job_name])
      unless job.valid?
        job.assure_name_and_description
        job.save!
      end
      imprintable_id = attributes[:imprintable]

      attributes[:colors].each do |color_attributes|
        next if color_attributes.nil?

        color_id = color_attributes[:color]

        LineItem.create_imprintables(job, imprintable_id, color_id)

        color_attributes[:sizes].each do |size_attributes|
          next if size_attributes.nil?

          size_id = size_attributes[:size]

          variant_id = ImprintableVariant
            .where(id: job.line_item_ids)
            .where(size_id: size_id, color_id: color_id)
            .readonly(false)
            .pluck(:id)
            .first

          job.line_items
            .find_by(imprintable_object_id: variant_id)
            .update_attributes(quantity: size_attributes[:quantity])
        end
      end
    end
  end
end
