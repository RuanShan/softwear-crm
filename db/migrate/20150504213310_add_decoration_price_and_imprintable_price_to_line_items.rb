class AddDecorationPriceAndImprintablePriceToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :decoration_price, :decimal, precision: 10, scale: 2
    add_column :line_items, :imprintable_price, :decimal, precision: 10, scale: 2
  end
end
