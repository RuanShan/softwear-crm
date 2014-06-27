class Payment < ActiveRecord::Base
  acts_as_paranoid

  default_scope { order(:created_at).with_deleted }

  belongs_to :order
  belongs_to :store
  belongs_to :user, foreign_key: :salesperson_id

  validates :store, presence: true

  def is_refunded?
    self.refunded == true
  end
end
