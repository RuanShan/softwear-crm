class Job < ActiveRecord::Base
  belongs_to :order

  validates_presence_of :name
  validates :name, uniqueness: { scope: :order_id }
end
