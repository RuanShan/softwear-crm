class PaymentDrop < ActiveRecord::Base
  acts_as_paranoid

  paginates_per 20

  CASH_PAYMENT_METHOD = 1

  belongs_to :store
  belongs_to :salesperson, class_name: 'User'
  has_many :payment_drop_payments, dependent: :destroy
  has_many :payments, through: :payment_drop_payments

  validates :salesperson, :store, :cash_included, presence: true
  validates :difference_reason, presence: true, unless: :cash_included_matches_total_cash?

  accepts_nested_attributes_for :payment_drop_payments, allow_destroy: true

  default_scope -> { order(created_at: :desc) }

  after_save -> { payments.each{|p| Sunspot.index(p) } }

  def total_amount
    payments
        .map{|x| x.amount}
        .reduce(0, :+)
  end

  def total_amount_for_payment_method(payment_method)
    payments.where(payment_method: payment_method)
        .map{|x| x.amount}
        .reduce(0, :+)
  end

  def cash_included_matches_total_cash?
    Payment.where(payment_method: CASH_PAYMENT_METHOD, id: payment_drop_payments.map(&:payment_id))
        .map{|x| x.amount}
        .reduce(0, :+)
        .to_f == cash_included.to_f
  end


end
