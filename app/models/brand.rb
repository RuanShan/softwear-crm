class Brand < ActiveRecord::Base
  acts_as_paranoid

  has_many :styles

  validates :name, uniqueness: true, presence: true
  validates :sku, uniqueness: true, presence: true, length: { is: 2 }
  validates :name, presence: true
end
