class RenameOrdersQuotes < ActiveRecord::Migration
  def change
    rename_table :orders_quotes, :order_quotes
  end
end
