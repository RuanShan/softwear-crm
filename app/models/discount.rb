class Discount < ActiveRecord::Base
  PAYMENT_METHODS = %w(PayPal Cash CreditCard Check)

  belongs_to :discountable, polymorphic: true
  belongs_to :applicator, polymorphic: true
  belongs_to :user

  validates :discount_method, inclusion: { in: PAYMENT_METHODS, message: "is not any of #{PAYMENT_METHODS.join(', ')}" }
  validates :order, presence: true
  validate :coupon_is_valid
  validates :reason, presence: true, if: :refund?

  after_validation :update_amount, if: :coupon?

  acts_as_paranoid

  def refund?
    applicator_type.blank?
  end

  def coupon?
    applicator_type == 'Coupon'
  end

  def order
    discountable if discountable_type == 'Order'
  end

  def coupon_code
    return unless coupon?
    applicator.try(:code)
  end
  def coupon_code=(code)
    self.applicator_type = 'Coupon'
    self.applicator_id = Coupon.where(code: code).pluck(:id).first
    if applicator_id.nil?
      @bad_coupon_code = "does not corrospond to any coupon in the system"
    end
    code
  end

  protected

  def update_amount
    return if applicator.nil?

    if discountable_type == 'Order'
      self.amount = applicator.calculate(discountable)
    elsif discountable_type == 'Job'
      self.amount = discountable.calculate(discountable.order, discountable)
    else
      raise "Unsupported discountable type #{discountable_type} with coupon"
    end
  end

  def coupon_is_valid
    if @bad_coupon_code
      errors.add(:coupon_code, @bad_coupon_code)
      @bad_coupon_code = nil
    end

    coupon = applicator
    return unless coupon.is_a?(Coupon)

    if coupon.valid_from > Time.now
      errors.add(:coupon, "is not set to activate until #{coupon.valid_from.strftime('%m/%d/%Y %I:%M%p')}")
    elsif Time.now > coupon.valid_until
      errors.add(:coupon, "expired on #{coupon.valid_until.strftime('%m/%d/%Y %I:%M%p')}")
    else
      true
    end
  end
end
