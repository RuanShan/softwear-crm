class FixInStoreCreditAmountPrecision < ActiveRecord::Migration
  def change
    change_column :in_store_credits, :amount, :decimal, precision: 10, scale: 2
  end
end
