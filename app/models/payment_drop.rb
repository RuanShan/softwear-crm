class PaymentDrop < ActiveRecord::Base
  include PublicActivity::Model
  include BelongsToUser

  tracked only: [:new, :update], parameters: :tracked_values, owner: Proc.new{ |controller, model| controller.current_user }
  acts_as_paranoid
  paginates_per 20

  CASH_PAYMENT_METHOD = 1
  CHECK_PAYMENT_METHOD = 3

  belongs_to :store
  belongs_to_user_called :salesperson
  has_many :payment_drop_payments, dependent: :destroy
  has_many :payments, through: :payment_drop_payments

  validates :salesperson_id, :store, :cash_included, :check_included, presence: true
  validates :difference_reason, presence: true, unless: :included_matches_total?
  validates :payments, presence: true

  accepts_nested_attributes_for :payment_drop_payments, allow_destroy: true

  default_scope -> { order(created_at: :desc) }

  after_save -> { payments.each{|p| Sunspot.index(p) } }

  def total_amount
    payments
        .map{|x| x.amount}
        .reduce(0, :+)
  end

  def payment_totals_hash
    Payment::VALID_PAYMENT_METHODS.map{ |key, val|
      {
          key => self.total_amount_for_payment_method(key)
      }
    }.reduce Hash.new, :merge
  end

  def total_amount_for_payment_method(payment_method)
    payments.where(payment_method: payment_method)
        .map{|x| x.amount}
        .reduce(0, :+)
  end

  def included_matches_total?
    cash_included_matches_total_cash? && check_included_matches_total_check?
  end

  def cash_included_matches_total_cash?
    Payment.where(payment_method: CASH_PAYMENT_METHOD, id: payment_drop_payments.map(&:payment_id))
        .map{|x| x.amount}
        .reduce(0, :+)
        .to_f == cash_included.to_f
  end


  def check_included_matches_total_check?
    Payment.where(payment_method: CHECK_PAYMENT_METHOD, id: payment_drop_payments.map(&:payment_id))
        .map{|x| x.amount}
        .reduce(0, :+)
        .to_f == check_included.to_f
  end

  def tracked_values
    {
      cash_included: cash_included,
      check_included: check_included
    }.merge(payment_totals_hash)
  end

end
