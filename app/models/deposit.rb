class Deposit < ActiveRecord::Base
  include PublicActivity::Model
  include Softwear::Auth::BelongsToUser

  tracked
  acts_as_paranoid
  paginates_per 20

  has_many :payment_drops
  has_many :payments, through: :payment_drops
  belongs_to_user_called :depositor, foreign_key: 'depositor_id'

  validates :payment_drops, presence: true
  validates :cash_included, :depositor_id, :check_included, :deposit_id, :deposit_location, presence: true
  validates :difference_reason, presence: true, unless: :included_matches_total?

  def total_amount
    payments
      .map{|x| x.amount}
      .reduce(0, :+)
  end

  def total_included
    cash_included + check_included
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

  def expected_total_included
    total_expected_cash + total_expected_check
  end

  def total_expected_cash
    payment_drops
      .map{|x| x.cash_included}
      .reduce(0.0, :+)
  end

  def total_expected_check
    payment_drops
      .map{|x| x.check_included}
      .reduce(0.0, :+)
  end

  private

  def included_matches_total?
    cash_included_matches_total_cash? && check_included_matches_total_check?
  end

  def cash_included_matches_total_cash?
    total_expected_cash == cash_included.to_f
  end


  def check_included_matches_total_check?
    total_expected_check == check_included.to_f
  end

end
