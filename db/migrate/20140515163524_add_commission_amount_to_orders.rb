class AddCommissionAmountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :commission_amount, :decimal, precision: 10, scale: 2
  end
end
