class Discount < ActiveRecord::Base
  include PublicActivity::Common

  PAYMENT_METHODS = %w(PayPal Cash CreditCard Check RefundPayment)

  belongs_to :discountable, polymorphic: true
  belongs_to :applicator, polymorphic: true
  belongs_to :user

  validates :discount_method, inclusion: { in: PAYMENT_METHODS, message: "is not any of #{PAYMENT_METHODS.join(', ')}" }, if: :refund?
  validates :discountable, presence: { message: " must be assigned" }
  validates :amount, presence: true
  validate :coupon_is_valid
  validates :reason, presence: true, if: :needs_reason?
  validate :refund_is_valid, if: :refund?

  before_validation :calculate_amount, if: :coupon?
  before_validation :set_amount, if: :in_store_credit?
  # The javascript will set transaction_id automatically.
  # By not doing this callback, one can choose not to have the refund to through payflow.
  #
  # before_validation :set_transaction_id, if: :refund?
  after_validation :apply_refund, on: :create, if: :refund?
  after_save :recalculate_order_fields
  after_destroy :recalculate_order_fields

  acts_as_paranoid

  scope :coupon, -> { where(applicator_type: 'Coupon') }

  attr_reader :credited_for_refund
  alias_method :credited_for_refund?, :credited_for_refund

  def applicator
    applicator_type == 'Refund' ? nil : super
  end

  def refund?
    applicator_type == 'Refund'
  end

  def discount?
    applicator_type.blank?
  end

  def needs_reason?
    refund? or discount?
  end

  def coupon?
    applicator_type == 'Coupon'
  end

  def in_store_credit?
    applicator_type == 'InStoreCredit'
  end

  def order
    if discountable_type == 'Order'
      discountable
    elsif discountable_type == 'Job'
      discountable.jobbable
    elsif discountable_type == 'Payment'
      discountable.order
    end
  end

  def discount_type
    case applicator_type
    when 'Coupon'        then 'coupon'
    when 'InStoreCredit' then 'in_store_credit'
    when 'Refund'        then 'refund'
    else 'discount'
    end
  end

  def coupon_code
    return unless coupon?
    applicator.try(:code)
  end
  def coupon_code=(code)
    self.applicator_type = 'Coupon'
    self.applicator_id = Coupon.where(code: code).pluck(:id).first

    if applicator_id.nil?
      @bad_coupon_code = "does not correspond to any coupon in the system"
    else

      if !applicator.valid_from.blank? && Time.now < applicator.valid_from
        @bad_coupon_code = "will be valid starting #{applicator.valid_from.strftime('%m/%d/%Y %I:%M%p')}"

      elsif !applicator.valid_until.blank? && Time.now > applicator.valid_until
        @bad_coupon_code = "corresponds to a coupon that expired on #{applicator.valid_until.strftime('%m/%d/%Y %I:%M%p')}!"
      end
    end
    code
  end

  def calculate_amount
    return if applicator.nil? || discountable.nil?

    if discountable_type == 'Order'
      self.amount = applicator.calculate(discountable)
    elsif discountable_type == 'Job'
      self.amount = applicator.calculate(discountable.order, discountable)
    else
      raise "Unsupported discountable type #{discountable_type} with coupon"
    end
  end

  protected

  def set_amount
    return if applicator.nil?

    self.amount = applicator.amount
  end

  def set_transaction_id
    return unless discountable.respond_to?(:cc_transaction)

    self.transaction_id = discountable.cc_transaction
  end

  # Payment implements validate_refund
  def refund_is_valid
    discountable.try(:validate_refund, self)
  end

  def apply_refund
    if discountable.respond_to?(:refund!) && !transaction_id.blank?
      @credited_for_refund = discountable.refund!(amount)
    end
    nil
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

  def recalculate_order_fields
    order.try(:recalculate_coupons) if coupon?

    if discountable_type == 'Payment'
      order.try(:recalculate_payment_total!)
    else
      order.try(:recalculate_discount_total!)
    end
  end
end
