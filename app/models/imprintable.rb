class Imprintable < ActiveRecord::Base
  belongs_to :style
  has_one :brand, through: :style

  validates_presence_of :style

  inject NonDeletable

  def name
    "#{style.catalog_no} #{style.name}"
  end
end
