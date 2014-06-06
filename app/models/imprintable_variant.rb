class ImprintableVariant < ActiveRecord::Base
  belongs_to :imprintable
  belongs_to :size
  belongs_to :color

  validates_presence_of :imprintable, :size, :color

  inject NonDeletable

  def description; imprintable.description; end
  def name 
    "#{color.name} #{imprintable.name}"
  end
  def style_name
    imprintable.style.name
  end
  def style_catalog_no
    imprintable.style.catalog_no
  end
end
