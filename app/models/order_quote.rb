class OrderQuote < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :order
  belongs_to :quote
end
