class Discount < ActiveRecord::Base
  PAYMENT_METHODS = %w(PayPal Cash CreditCard Check)

  belongs_to :discountable, polymorphic: true
  belongs_to :applicator, polymorphic: true
  belongs_to :user

  validates :reason, presence: true, if: :refund?
  validates :discount_method, inclusion: { in: PAYMENT_METHODS, message: "is not any of #{PAYMENT_METHODS.join(', ')}" }
  validates :order, presence: true

  acts_as_paranoid

  def refund?
    applicator.nil?
  end

  def order
    discountable if discountable_type == 'Order'
  end
end
