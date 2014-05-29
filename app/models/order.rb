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

  belongs_to :user
  has_many :jobs

  # non-deletable stuff
  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil) }

  def destroyed?
    !deleted_at.nil?
  end

  def destroy
    update_attribute(:deleted_at, Time.now)
  end

  def destroy!
    update_column(:deleted_at, Time.now)
  end

  def revive
    update_attribute(:deleted_at, nil) if !deleted_at.nil?
  end

private
  def initialize_fields
    self.sales_status = 'Pending' if self.sales_status.nil? or self.sales_status.empty?
    ## Additionally, grab the correct edit template
  end
end