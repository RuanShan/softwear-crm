class Brand < ActiveRecord::Base
  has_many :styles
  # has_one :imprintable, through: :style

  validates :name, uniqueness: true, presence: true
  validates :sku, uniqueness: true, presence: true
  validates :name, presence: true

  inject NonDeletable
end
