class LineItemGroup < ActiveRecord::Base
  acts_as_paranoid

  has_many :line_items, as: :line_itemable
  belongs_to :quote
end