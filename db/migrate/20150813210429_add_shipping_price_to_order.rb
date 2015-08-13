class AddShippingPriceToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_price, :decimal, precision: 10, scale: 2, default: 0.0 
  end
end
