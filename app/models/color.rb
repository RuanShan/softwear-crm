class Color < ActiveRecord::Base
  include Retailable

  acts_as_paranoid

  has_many :imprintable_variants, dependent: :destroy

  validates :name, uniqueness: true, presence: true
  validates :sku, length: { is: 3 }, if: :is_retail?


end
