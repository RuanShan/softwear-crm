class Payment < ActiveRecord::Base
  acts_as_paranoid

  # TODO: this doesn't seem right
  default_scope { order(:created_at).with_deleted }

  belongs_to :order
  belongs_to :store
  belongs_to :salesperson, class_name: User

  validates :store, presence: true

  def is_refunded?
    refunded
  end
end
