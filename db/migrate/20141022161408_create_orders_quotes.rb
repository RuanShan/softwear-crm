class CreateOrdersQuotes < ActiveRecord::Migration
  def change
    create_table :orders_quotes do |t|
      t.integer :order_id
      t.integer :quote_id

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
