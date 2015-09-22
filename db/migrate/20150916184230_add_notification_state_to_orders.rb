class AddNotificationStateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :notification_state, :string, indexed: true
    Order.all.each{|o| o.update_attribute(:notification_state, :pending) }
  end
end
