class Brand < ActiveRecord::Base
  include Retailable

  acts_as_paranoid

  default_scope { order(:name) }

  has_many :imprintables

  validates :name, uniqueness: true, presence: true
  validates :sku, length: { is: 2 }, if: :is_retail?
end
