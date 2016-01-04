class AddCheckingTotalToDrop < ActiveRecord::Migration
  def change
    add_column :payment_drops, :check_included, :decimal, precision: 10, scale: 2

    PaymentDrop.all.each do |pd|
      pd.update_column(:check_included, pd.total_amount_for_payment_method(3))
    end
  end
end
