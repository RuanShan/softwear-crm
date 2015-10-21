class Payment < ActiveRecord::Base
  include PublicActivity::Common

  VALID_PAYMENT_METHODS = {
    1 => 'Cash',
    2 => 'Swiped Credit Card',
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

  acts_as_paranoid

  default_scope { order(:created_at) }

  belongs_to :order
  belongs_to :store
  belongs_to :salesperson, class_name: User

  validates :store, :payment_method, :amount, :salesperson, presence: true
  validates :pp_transaction_id, presence: true, if: Proc.new{ |p| p.payment_method == 4 || p.payment_method == 7 }
  validates :t_name, :t_company_name, :tf_number, presence: true, if: Proc.new{ |p| p.payment_method == 5 }
  validates :t_name, :t_company_name, :t_description, presence: true, if: Proc.new{ |p| p.payment_method == 6 }

  def is_refunded?
    refunded
  end
end
