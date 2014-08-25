class AddShippingToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :shipping, :decimal, precision: 10, scale: 2
  end
end
