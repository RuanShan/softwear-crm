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
    2 => [:cc_name, :cc_company, :cc_number, :cc_transaction],
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
    jcb:                       'JCB',
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
  validates :cc_number, :cc_name, presence: true, if: :credit_card?
  validate :amount_doesnt_overflow_order_balance
  validate :credit_card_is_valid, if: :credit_card?

  # NOTE These are all transient and only ever exist on the instance of a CC payment being made
  attr_reader :actual_cc_number
  attr_accessor :cc_expiration
  attr_accessor :cc_cvc

  def is_refunded?
    refunded
  end

  def credit_card?
    payment_method == 2
  end

  def cc_number=(new_cc_number)
    return super if new_cc_number.blank?
    return super if /x+/ =~ new_cc_number

    stored_value = ''
    new_cc_number.each_char.with_index do |c, i|
      if /\s/ =~ c
        stored_value << c
      elsif i >= new_cc_number.size - 4
        stored_value << c
      else
        stored_value << 'x'
      end
    end

    # Only store this in memory
    @actual_cc_number = new_cc_number

    super(stored_value)
  end

  def credit_card
    return @credit_card if @credit_card
    return if actual_cc_number.blank? || cc_expiration.blank? || cc_cvc.blank?

    # (first_name: nonwhitespace)(whitespace)(last_name: nonwhitespace)
    /^(?<first_name>\S+)\s+(?<last_name>.+)$/ =~ cc_name
    # (month: 1 or 2 digits)(slash)(year: 2 digits)
    /(?<month>\d\d?)\/(?<year>\d\d)/ =~ cc_expiration

    current_year = Time.now.year.to_s
    if current_year.size > 4
      raise "8000 years have past since the creation of this software!!!"
    end
    # "20" from current year + "19" (for example) from input value for "2019"
    year = current_year[0...2] + year

    @credit_card = ActiveMerchant::Billing::CreditCard.new(
      first_name:         first_name,
      last_name:          last_name,
      number:             actual_cc_number.gsub(/\s+/, ''),
      month:              month,
      year:               year,
      verification_value: cc_cvc
    )
  end

  private

  def credit_card_is_valid
    if credit_card.nil?
      errors.add(:cc_expiration, 'required') if cc_expiration.blank?
      errors.add(:cc_cvc, 'required') if cc_cvc.blank?
      errors.add(:cc_number, 'must be re-entered') if /x+/ =~ cc_number
      return
    end

    card_errors = credit_card.validate
    unless card_errors.empty?
      if card_errors[:year] || card_errors[:month]
        errors.add(:cc_expiration, [card_errors.delete(:year), card_errors.delete(:month)].compact.uniq)
      end
      unless card_errors.empty?
        errors.add(:cc_number, card_errors.to_a.map { |e| "#{e[0]} #{e[1]}" }.join(', '))
      end
      return
    end
  end

  def amount_doesnt_overflow_order_balance
    return if order_id.blank? || amount.blank?

    order_balance = order.balance_excluding(self)
    new_balance = order_balance - amount
    if new_balance < 0
      errors.add(
        :amount,
        "overflows the order's balance by #{number_to_currency(-new_balance)} "\
        "(set to #{number_to_currency(order_balance)} to complete payment)"
      )
    end
  end
end
