class Payment < ActiveRecord::Base
  include PublicActivity::Common

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
