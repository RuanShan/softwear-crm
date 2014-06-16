class Color < ActiveRecord::Base
  acts_as_paranoid

  has_many :imprintable_variants, dependent: :destroy

  validates :name, uniqueness: true, presence: true
  validates :sku, uniqueness: true, presence: true, length: { is: 3 }
end
