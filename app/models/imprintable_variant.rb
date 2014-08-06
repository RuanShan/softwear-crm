class ImprintableVariant < ActiveRecord::Base
  extend ParamHelpers

  acts_as_paranoid

  belongs_to :color
  belongs_to :imprintable
  belongs_to :size

  #TODO: validating color_id?
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

  def brand
    imprintable.brand
  end

  def description
    imprintable.description
  end

  def full_name
    "#{brand.name} #{imprintable.style_catalog_no} #{color.name} #{size.name}"
  end

  def name 
    "#{color.name} #{imprintable.name}"
  end

  def style_catalog_no
    imprintable.style_catalog_no
  end

  def style_name
    imprintable.style_name
  end
end
