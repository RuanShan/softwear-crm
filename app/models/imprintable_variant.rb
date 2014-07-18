class ImprintableVariant < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprintable
  belongs_to :size
  belongs_to :color

  validates :imprintable, presence: true
  validates :size, presence: true
  validates :color, presence: true
  validates :color_id, uniqueness: { scope: [:size_id, :imprintable_id] }

  def full_name
    "#{ brand.name } #{ imprintable.style_catalog_no } #{ color.name } #{ size.name }"
  end

  def description
    imprintable.description
  end

  def name 
    "#{ color.name } #{ imprintable.name }"
  end

  def style_name
    imprintable.style_name
  end

  def style_catalog_no
    imprintable.style_catalog_no
  end

  def brand
    imprintable.brand
  end

end
