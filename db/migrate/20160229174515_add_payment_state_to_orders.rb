class AddPaymentStateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment_state, :string

    Order.unscoped.find_each do |o|
      o.update_column :payment_state, o.calculate_payment_state
    end
    puts "Calculated payment states for all orders."
  end
end
