class AddRefundAmountToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :refund_amount, :decimal, precision: 10, scale: 2
  end
end
