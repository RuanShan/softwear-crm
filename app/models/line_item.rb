class LineItem < ActiveRecord::Base
  belongs_to :job
  belongs_to :imprintable_variant

  validates_presence_of :name

  inject NonDeletable

  def price; unit_price * quantity; end
end