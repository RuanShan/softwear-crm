class AddCanceledToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :canceled, :boolean
  end
end
