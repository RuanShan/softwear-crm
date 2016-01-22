class UserAttributes < ActiveRecord::Base
  CUSTOMER_EMAIL = "customer@softwearcrm.com"
  SALES_MANAGERS = %w(
    ricky@annarbortees.com
    jack@annarbortees.com
    jerry@annarbortees.com
    nate@annarbortees.com
    michael@annarbortees.com
    chantal@annarbortees.com
    kenny@annarbortees.com
    nigel@annarbortees.com
    shannon@annarbortees.com
  )

  attr_encrypted :freshdesk_password, key: 'h4rdc0ded1337ness'

  devise(:database_authenticatable, :confirmable, :recoverable, :registerable,
         :rememberable, :trackable, :timeoutable, :validatable, :lockable)

  belongs_to :store
  has_many :orders
  has_many :quote_requests, foreign_key: 'salesperson_id'
  has_many :pending_quote_requests, -> {where.not(status: 'quoted')}, foreign_key: 'salesperson_id', class_name: 'QuoteRequest'
  has_many :search_queries, class_name: 'Search::Query'
  belongs_to :signature, class_name: 'Asset'

  accepts_nested_attributes_for :signature

  validates :freshdesk_email, email: true, allow_blank: true
  
  after_save :assign_image_assetables

  def self.customer
    customer_user = find_by(email: CUSTOMER_EMAIL)
    return customer_user unless customer_user.nil?

    User.create(
      email: CUSTOMER_EMAIL,
      first_name: 'Ann Arbor Tees',
      last_name: 'Customer',
      password: "Aa7cCust0m4rP455",
      password_confirmation: "Aa7cCust0m4rP455"
    )
  end

  def customer?
    email == CUSTOMER_EMAIL
  end

  def sales_manager?
    SALES_MANAGERS.include?(email) || Rails.env.test?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  # Don't assign attachment attributes if no file is specified
  def signature_attributes=(attrs)
    super(attrs) unless attrs[:file].blank?
  end

  private

  # We use belongs_to for the images, because you cannot have two has_ones of the
  # same type. Because of this, the assets don't get the assetable information they
  # need for paths. This is a quick fix for that.
  def assign_image_assetables
    signature.assetable = self
    signature.save(validate: false)
  end
end
