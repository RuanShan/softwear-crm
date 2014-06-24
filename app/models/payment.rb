class Payment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :order
  belongs_to :store
  belongs_to :user, foreign_key: :salesperson_id

  validates :store, presence: true

  def is_refunded?
    self.refunded
  end
end
