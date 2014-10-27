class Order < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid

  is_activity_recipient

  searchable do
    text :name, :email, :firstname, :lastname,
         :company, :twitter, :terms, :delivery_method

    text :jobs do
      jobs.map { |j| "#{j.name} #{j.description}" }
    end

    [
      :firstname, :lastname, :email, :terms,
      :delivery_method, :company, :phone_number
    ]
      .each { |f| string f }

    double :total
    double :commission_amount

    date :in_hand_by

    reference :salesperson
  end

  tracked by_current_user

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

  belongs_to :salesperson, class_name: User
  belongs_to :store
  has_many :jobs
  has_many :artwork_requests, through: :jobs
  has_many :imprints, through: :jobs
  has_many :payments
  has_many :proofs
  has_many :orders_quotes, class_name: OrdersQuotes
  has_many :quotes, through: :orders_quotes

  accepts_nested_attributes_for :payments

  # TODO: custom validator for phone?
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
  validates :tax_id_number, presence: true, if: :tax_exempt?
  validates :terms, presence: true

  scope :fba, -> { where(terms: 'Fulfilled by Amazon') }

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
      case terms
      when 'Paid in full on purchase'
          'Awaiting Payment'
      when 'Half down on purchase'
        balance >= (total * 0.49) ? 'Awaiting Payment' : 'Payment Terms Met'
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

  def subtotal
    line_items.map(&:total_price).reduce(0, :+)
  end

  def tax
    0.06
  end

  def total
    subtotal + subtotal * tax
  end

  def name_number_csv
    csv = imprints
      .with_name_number
      .map { |i| [i.name_number.number, i.name_number.name] }

    CSV.from_arrays csv, headers: %w(Number Name), write_headers: true
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

          job.line_items
            .joins(:imprintable_variant)
            .where(imprintable_variants: { size_id: size_id, color_id: color_id })
            .readonly(false)
            .first
            .update_attributes(quantity: size_attributes[:quantity])
        end
      end
    end
  end
end
