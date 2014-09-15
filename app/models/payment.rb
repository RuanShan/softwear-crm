class Payment < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  tracked by_current_user

  default_scope { order(:created_at) }

  belongs_to :order
  belongs_to :store
  belongs_to :salesperson, class_name: User

  validates :store, presence: true

  def is_refunded?
    refunded
  end
end
