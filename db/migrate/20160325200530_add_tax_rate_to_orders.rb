class AddTaxRateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :tax_rate, :decimal, precision: 10, scale: 2

    Order.unscoped.update_all tax_rate: 0.06
    puts "  Set tax rate of existing orders to 0.06"
  end
end
