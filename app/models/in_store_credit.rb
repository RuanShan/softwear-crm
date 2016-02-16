class InStoreCredit < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include BelongsToUser

  validates :name, :customer_email, :amount, :description, :user_id, :valid_until, presence: true
  validates :name, uniqueness: true

  before_validation :populate_fields_from_order, if: :order_id
  after_create :create_job_and_line_item, if: :order_id

  belongs_to_user
  has_one :discount, as: :applicator

  attr_accessor :order_id
  attr_reader :job

  searchable do
    text :name, :customer_name, :tokenize_email, :description

    boolean :used
    integer :id
    date :valid_until
  end

  def customer_name
    "#{customer_first_name} #{customer_last_name}"
  end

  def used?
    !discount.nil? && discount.discountable_id && !discount.deleted_at
  end
  alias_method :used, :used?

  def tokenize_email
    customer_email.gsub(/[@\.]/, ' ')
  end

  def order
    return @order unless @order.nil?

    raise "No order specified for in-store credit" if order_id.nil?
    @order = Order.find(order_id)
  end

  protected

  def populate_fields_from_order
    self.customer_email      = order.email
    self.customer_first_name = order.firstname
    self.customer_last_name  = order.lastname
  end

  def create_job_and_line_item
    line_item = LineItem.new(
      name:        "In-Store Credit ##{id}",
      description: %(In-store credit of #{number_to_currency(amount)} issued because "#{description}"),
      quantity:    1,
      unit_price:  0,
    )

    job = order.jobs.find_or_create_by(name: "In-Store Credit")
    job.description ||= "In-store credits issued because of this order"
    job.line_items << line_item

    @job = job

    job.save! and line_item.save!
  end
end
