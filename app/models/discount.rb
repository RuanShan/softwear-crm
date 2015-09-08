class Discount < ActiveRecord::Base
  PAYMENT_METHODS = %w(PayPal Cash CreditCard Check)

  belongs_to :discountable, polymorphic: true
  belongs_to :applicator, polymorphic: true
  belongs_to :user

  validates :reason, presence: true, if: :refund?
  validates :discount_method, inclusion: { in: PAYMENT_METHODS, message: "is not any of #{PAYMENT_METHODS.join(', ')}" }
  validates :order, presence: true

  before_validation :update_amount, if: :coupon?

  acts_as_paranoid

  def refund?
    applicator.nil?
  end

  def coupon?
    applicator_type == 'Coupon'
  end

  def order
    discountable if discountable_type == 'Order'
  end

  protected

  def update_amount
    if discountable_type == 'Order'
      self.amount = applicator.calculate(discountable)
    elsif discountable_type == 'Job'
      self.amount = discountable.calculate(discountable.order, discountable)
    else
      raise "Unsupported discountable type #{discountable_type} with coupon"
    end
  end
end
