class LineItem < ActiveRecord::Base
  belongs_to :job

  validates_presence_of :name

  inject NonDeletable

  def price; unit_price * quantity; end
end