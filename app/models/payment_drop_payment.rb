class PaymentDropPayment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :payment
  belongs_to :payment_drop

  validates :payment_id, uniqueness: true

end
