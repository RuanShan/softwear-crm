class Order < ActiveRecord::Base

  VALID_PAYMENT_TERMS = ['', 
     'Paid in full on purchase',
     'Half down on purchase',
     'Paid in full on pick up',
     'Net 30',
     'Net 60']

  VALID_SALES_STATUSES   = ['Pending', 'Terms Set And Met', 'Paid', 'Cancelled']
  VALID_DELIVERY_METHODS = ['Pick up in Ann Arbor', 'Pick up in Ypsilanti', 'Ship to one location', 'Ship to multiple locations']
  
  before_validation :initialize_fields, on: :create

  validates_presence_of :email, :firstname, :lastname, :name, :terms, :delivery_method
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :phone_number, format: { with: /\d{3}-\d{3}-\d{4}/, message: "is incorrectly formatted, use 000-000-0000" }
  
  validates_inclusion_of(:sales_status, 
      in: VALID_SALES_STATUSES,
      message: "is not a valid sales status")

  validates_inclusion_of(:delivery_method,
      in: VALID_DELIVERY_METHODS,
      message: 'Invalid delivery method')

  validates_presence_of :tax_id_number, if: :tax_exempt?
  validates_presence_of :redo_reason, if: :is_redo?
  validates :store, presence: true
  validates :salesperson_id, presence: true

  belongs_to :user
  belongs_to :store
  has_many :jobs

  acts_as_paranoid

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

  searchable do
    text :name, :email, :firstname, :lastname, :company, :twitter, :terms, :delivery_method, :sales_status
    # text :jobs do
    #   jobs.map { |j| "#{j.name} #{j.description}" }
    # end

    [:firstname, :lastname, :email, :terms, :delivery_method, :sales_status].each do |field|
      string field
    end

    double :total
    double :commission_amount

    date :in_hand_by

    reference :salesperson
  end

private
  def initialize_fields
    self.sales_status = 'Pending' if self.sales_status.nil? or self.sales_status.empty?
  end
end
