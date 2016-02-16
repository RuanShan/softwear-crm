class User < AuthModel
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

  has_many :orders,         foreign_key: 'salesperson_id'
  has_many :quote_requests, foreign_key: 'salesperson_id'
  has_many :search_queries, class_name: 'Search::Query'

  expire_query_cache_every 2.minutes if Rails.env.development?

  def pending_quote_requests
    quote_requests.where.not(status: 'quoted')
  end

  def self.customer
    new(
      id: 0,
      email: CUSTOMER_EMAIL,
      first_name: 'Ann Arbor Tees',
      last_name: 'Customer'
    )
  end

  def sales_manager?
    SALES_MANAGERS.include?(email) || Rails.env.test?
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
