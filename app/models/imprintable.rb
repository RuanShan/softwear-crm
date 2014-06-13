class Imprintable < ActiveRecord::Base
  acts_as_paranoid

  SIZING_CATEGORIES = ['Adult Unisex', 'Ladies', 'Youth Unisex', 'Girls', 'Toddler', 'Infant']

  belongs_to :style
  has_one :brand, through: :style, dependent: :destroy
  has_many :imprintable_variants, dependent: :destroy
  has_many :colors, through: :imprintable_variants, dependent: :destroy
  has_many :sizes, through: :imprintable_variants, dependent: :destroy
  has_and_belongs_to_many :coordinates, class_name: 'Imprintable', association_foreign_key: 'imprintable_id', join_table: 'imprintable_linker_table'
  has_and_belongs_to_many :sample_locations, class_name: 'Store', association_foreign_key: 'store_id', join_table: 'imprintable_linker_table'

  validates :style, presence: true
  validates :sizing_category, inclusion: { in: SIZING_CATEGORIES, message: 'Invalid sizing category' }

  def name
    "#{style.catalog_no} #{style.name}"
  end

  def description
    style.description
  end

  def find_variants
    if self.id
      ImprintableVariant.includes(:size, :color).where(imprintable_id: self.id)
    end
  end

  def create_variants_hash
    variants = self.find_variants
    variants_array = variants.to_a
    size_variants = variants_array.uniq{ |v| v.size_id }
    size_variants.sort! { |x,y| x.size.sort_order <=> y.size.sort_order }

    color_variants = variants_array.uniq{ |v| v.color_id }
    { :size_variants => size_variants, :color_variants => color_variants, :variants_array => variants_array }
  end
end
