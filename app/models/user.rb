class User < Softwear::Auth::Model
  CUSTOMER_EMAIL = "customer@softwearcrm.com"

  has_many :orders,         foreign_key: 'salesperson_id'
  has_many :quote_requests, foreign_key: 'salesperson_id'
  has_many :search_queries, class_name: 'Search::Query'

  expire_query_cache_every 5.minutes if Rails.env.development?

  def pending_quote_requests
    quote_requests.where.not(status: 'quoted')
  end

  # override
  def self.auth_server_down_mailer
    ErrorReportMailer
  end

  def self.customer
    new(
      id: 0,
      email: CUSTOMER_EMAIL,
      first_name: 'Ann Arbor Tees',
      last_name: 'Customer'
    )
  end

  def is_in_sales?
    self.role?('sales_manager') || self.role?('salesperson')
  end

  def sales_manager?
    self.role?('sales_manager') || Rails.env.test?
  end

  def customer?
    id == 0
  end

  def attributes
    return nil if id.blank?
    @attributes ||= UserAttributes.find_or_create_by(user_id: id)
  end

  # override
  def find(target_id)
    return User.customer if target_id.to_s == '0'
    super
  end

  def respond_to?(name, *a)
    super || attributes.respond_to?(name, *a)
  end

  def method_missing(name, *args, &block)
    if attributes.respond_to?(name)
      attributes.send(name, *args, &block)
    else
      raise NoMethodError.new("undefined method `#{name}' called on instance of User")
    end
  end
end
