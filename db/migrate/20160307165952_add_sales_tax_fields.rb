class AddSalesTaxFields < ActiveRecord::Migration
  def change
    add_column :payments, :sales_tax_amount,  :decimal, precision: 10, scale: 2
  end
end
