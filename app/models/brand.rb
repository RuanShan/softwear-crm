class Brand < ActiveRecord::Base
  acts_as_paranoid

  include Retailable

  has_many :styles, dependent: :destroy

  validates :name, uniqueness: true, presence: true
  validates :sku, length: { is: 2 }, if: :is_retail?

  default_scope { order(:name) }
end
