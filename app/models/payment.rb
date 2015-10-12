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

  acts_as_paranoid

  default_scope { order(:created_at) }

  belongs_to :order
  belongs_to :store
  belongs_to :salesperson, class_name: User

  validates :store, presence: true

  def is_refunded?
    refunded
  end
end
