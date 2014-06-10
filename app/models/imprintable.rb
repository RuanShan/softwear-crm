class Imprintable < ActiveRecord::Base
  acts_as_paranoid

  SIZING_CATEGORIES = ['Adult Unisex', 'Ladies', 'Youth Unisex', 'Girls', 'Toddler', 'Infant']

  belongs_to :style
  has_one :brand, through: :style
  has_many :imprintable_variants
  has_many :colors, through: :imprintable_variants
  has_many :sizes, through: :imprintable_variants

  validates :style, presence: true
  validates :sizing_category, inclusion: { in: SIZING_CATEGORIES, message: 'Invalid sizing category' }

  def name
    "#{style.catalog_no} #{style.name}"
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
