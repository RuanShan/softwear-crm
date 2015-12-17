class AddScaleToDiscountAmount < ActiveRecord::Migration
  def change
    change_column :discounts, :amount, :decimal, precision: 10, scale: 2
  end
end
