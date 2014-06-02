class ImprintableVariant < ActiveRecord::Base
  belongs_to :imprintable
  belongs_to :size
  belongs_to :color

  validates_presence_of :imprintable, :size, :color

  inject NonDeletable
end
