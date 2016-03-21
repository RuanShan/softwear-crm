class ImprintableVariant < ActiveRecord::Base
  extend ParamHelpers

  acts_as_paranoid

  belongs_to :color, inverse_of: :imprintable_variants
  belongs_to :imprintable, inverse_of: :imprintable_variants
  belongs_to :size, inverse_of: :imprintable_variants

  validates :color, presence: true
  validates :color_id, uniqueness: { scope: [:size_id, :imprintable_id] }
  validates :imprintable, presence: true
  validates :size, presence: true

  scope :size_variants_for, ->(imprintable, color) do
    where(
      imprintable_id: param_record_id(imprintable),
      color_id:       param_record_id(color)
    )
  end

  def brand_id
    imprintable.brand_id
  end

  def brand
    imprintable.brand
  end

  def description
    imprintable.description
  end

  def full_name
    "#{brand.name} #{imprintable.style_catalog_no} #{color.name} #{size.name}"
  end

  def fancy_name
    "#{brand.name} - #{imprintable.style_catalog_no} - #{color.name} - #{size.display_value}"
  end

  def name
    "#{imprintable.name}"
  end

  def style_catalog_no
    imprintable.style_catalog_no
  end

  def style_name
    imprintable.style_name
  end

  def sku
    "#{imprintable.sku}#{size.sku}#{color.sku}"
  end

  def size_display
    size.display_value || size.name
  end
end
