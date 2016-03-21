class Color < ActiveRecord::Base
  include Retailable

  acts_as_paranoid

  default_scope { order(:name) }

  has_many :imprintable_variants, dependent: :destroy, inverse_of: :color
  has_many :imprintables, through: :imprintable_variants

  validates :name, uniqueness: true, presence: true
  validates :sku, length: { is: 3 }, if: :is_retail?

  searchable do
    text :name, :sku, :map
    string :name
    string :map
    string :sku
    integer :id
  end

  def hexcodes
    (hexcode.try(:split, ',') || []).map { |v| '#'+v }
  end
  def hexcodes=(values)
    self.hexcode = values.map { |v| v.gsub('#', '') }.join(',')
  end
end
