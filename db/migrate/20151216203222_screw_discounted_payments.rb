class ScrewDiscountedPayments < ActiveRecord::Migration
  def change
    remove_column :payments, :refunded, :boolean
    remove_column :payments, :refund_amount, :boolean
  end
end
