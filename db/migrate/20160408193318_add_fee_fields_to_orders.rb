class AddFeeFieldsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :fee, :decimal, precision: 10, scale: 2
    add_column :orders, :fee_description, :string
  end
end
