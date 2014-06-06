class Imprintable < ActiveRecord::Base

  belongs_to :style
  has_one :brand, through: :style
  has_many :imprintable_variants
  has_many :colors, through: :imprintable_variants
  has_many :sizes, through: :imprintable_variants

  attr_accessor :valid_imprintable_variants_count

  validates_presence_of :style

  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil)}

  def destroyed?
    !deleted_at.nil?
  end

  def destroy
    update_attribute(:deleted_at, Time.now)
  end

  def destroy!
    update_column(:deleted_at, Time.now)
  end

  def name
    "#{style.catalog_no} #{style.name}"
  end

  def find_variants
    if self.id
      ImprintableVariant.includes(:size, :color).where("imprintable_id = #{self.id}")
    else
      []
    end
  end

  def create_variants_hash
    variants = self.find_variants
    variants_array = variants.to_a
    size_variants = variants_array.uniq{ |v| v.size_id }
    size_variants.sort! { |x,y| x.size.sort_order <=> y.size.sort_order }

    color_variants = variants_array.uniq{ |v| v.color_id }
    { :size_variants => size_variants, :color_variants => color_variants, :variants_array => variants_array}
  end
end
