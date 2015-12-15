class Payment < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include PublicActivity::Common

  VALID_PAYMENT_METHODS = {
    1 => 'Cash',
    2 => 'Credit Card',
    3 => 'Check',
    4 => 'PayPal',
    5 => 'Trade First',
    6 => 'Trade',
    7 => 'Wire Transfer'
  }

  FIELDS_TO_RENDER_FOR_METHOD = {
    3 => [:check_dl_no, :check_phone_no],
    4 => [:pp_transaction_id],
    5 => [:t_name, :t_company_name, :tf_number],
    6 => [:t_name, :t_company_name, :t_description],
    7 => [:pp_transaction_id]
  }

  CREDIT_CARD_TYPES = {
    amex:                      'American Express',
    diners_club_carte_blanche: 'Diners Club Carte Blanche',
    diners_club_international: 'Diners Club International',
    mastercard:                'MasterCard',
    discover:                  'Discover Card',
    jcp:                       'JCB',
    laser:                     'Laser',
    maestro:                   'Maestro',
    visa:                      'Visa',
    visa_electron:             'Visa electron'
  }

  acts_as_paranoid

  default_scope { order(:created_at) }

  belongs_to :order, touch: true
  belongs_to :store
  belongs_to :salesperson, class_name: User

  validates :store, :payment_method, :amount, :salesperson, presence: true
  validates :pp_transaction_id, presence: true, if: -> p { p.payment_method == 4 || p.payment_method == 7 }
  validates :t_name, :t_company_name, :tf_number, presence: true, if: -> p { p.payment_method == 5 }
  validates :t_name, :t_company_name, :t_description, presence: true, if: -> p { p.payment_method == 6 }
  validate :amount_doesnt_overflow_order_balance

  def is_refunded?
    refunded
  end

  private

  def amount_doesnt_overflow_order_balance
    return if order_id.blank?

    new_balance = order.balance_excluding(self) - amount
    if new_balance < 0
      errors.add(:amount, "overflows the order's balance by #{number_to_currency(-new_balance)}")
    end
  end
end
