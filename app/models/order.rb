class Order < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  tracked by_current_user

  VALID_PAYMENT_TERMS = ['', 
     'Paid in full on purchase',
     'Half down on purchase',
     'Paid in full on pick up',
     'Net 30',
     'Net 60']

  VALID_DELIVERY_METHODS = ['Pick up in Ann Arbor', 'Pick up in Ypsilanti', 'Ship to one location', 'Ship to multiple locations']

  validates_presence_of :email, :firstname, :lastname, :name, :terms, :delivery_method
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :phone_number, format: { with: /\d{3}-\d{3}-\d{4}/, message: "is incorrectly formatted, use 000-000-0000" }

  validates_inclusion_of(:delivery_method,
      in: VALID_DELIVERY_METHODS,
      message: 'Invalid delivery method')

  validates_presence_of :tax_id_number, if: :tax_exempt?
  validates :store, presence: true
  validates :salesperson_id, presence: true

  belongs_to :user, :foreign_key => :salesperson_id
  belongs_to :store
  has_many :jobs
  has_many :artwork_requests, through: :jobs
  has_many :payments

  accepts_nested_attributes_for :payments

  def all_activities
    PublicActivity::Activity.where( "
      (
        activities.recipient_type = ? AND activities.recipient_id = ?
      ) OR
      (
        activities.trackable_type = ? AND activities.trackable_id = ?
      )
    ", *([self.class.name, self.id] * 2) ).order('created_at DESC')
  end

  def line_items
    LineItem.where(job_id: job_ids)
  end

  def tax; 0.6; end

  def subtotal
    sum = 0
    line_items.each do |line_item|
      sum += line_item.price
    end
    sum
  end

  def total; subtotal + subtotal * tax; end

  def salesperson
    User.find(self.salesperson_id)
  end

  def salesperson_name
    User.find(self.salesperson_id).full_name
  end

  def payment_total
    total = 0
    self.payments.each do |payment|
      if !payment.nil? and !payment.is_refunded?
        total += payment.amount
      end
    end
    total
  end

  def balance
    self.total - self.payment_total
  end

  def percent_paid
    (self.payment_total / self.total)*100
  end

  def payment_status
    if self.terms.empty?
      'Payment Terms Pending'
    elsif self.balance <= 0
      return 'Payment Complete'
    elsif self.balance > 0
      if self.terms == 'Paid in full on purchase'
        return 'Awaiting Payment'
      elsif self.terms == 'Half down on purchase'
        if self.balance >= (total * 0.49)
          return 'Awaiting Payment'
        else
          return 'Payment Terms Met'
        end
      elsif self.terms == 'Paid in full on pick up'
        if Time.now >= self.in_hand_by
          return 'Awaiting Payment'
        else
          return 'Payment Terms Met'
        end
      elsif self.terms == 'Net 30'
        if Time.now >= (self.in_hand_by + 30.days)
          return 'Awaiting Payment'
        else
          return 'Payment Terms Met'
        end
      elsif self.terms == 'Net 60'
        if Time.now >= (self.in_hand_by + 60.days)
          return 'Awaiting Payment'
        else
          return 'Payment Terms Met'
        end
      end
    end
  end

  searchable do
    text :name, :email, :firstname, :lastname, :company, :twitter, :terms, :delivery_method
    text :jobs do
      jobs.map { |j| "#{j.name} #{j.description}" }
    end

    [:firstname, :lastname, :email, :terms, :delivery_method, :company, :phone_number].each do |field|
      string field
    end

    double :total
    double :commission_amount

    date :in_hand_by

    reference :salesperson
  end

end
