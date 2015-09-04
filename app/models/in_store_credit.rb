class InStoreCredit < ActiveRecord::Base
  validates :name, :customer_email, :amount, :description, :user_id, :valid_until, presence: true
  validates :name, uniqueness: true

  belongs_to :user

  def used?
    # TO BE IMPLEMENTED
    Random.rand(10) > 6
  end
end
