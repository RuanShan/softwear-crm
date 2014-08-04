class Payment < ActiveRecord::Base
  acts_as_paranoid

  # TODO: this doesn't seem right
  default_scope { order(:created_at).with_deleted }

  belongs_to :order
  belongs_to :store
  belongs_to :user, foreign_key: :salesperson_id

  validates :store, presence: true

  # TODO: make sure this works
  #   as opposed to self.refunded == true
  def is_refunded?
    refunded
  end
end
