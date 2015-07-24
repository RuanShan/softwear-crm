class LineItemTemplate < ActiveRecord::Base
  validates :name, :description, presence: true

  def into_line_item(line_itemable)
    LineItem.new(
      line_itemable: line_itemable,
      name:          name,
      description:   description,
      url:           url,
      unit_price:    unit_price
    )
  end
end
