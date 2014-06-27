class AddSupplierDataToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :main_supplier, :string
    add_index :imprintables, :main_supplier

    add_column :imprintables, :supplier_link, :string
    add_column :imprintables, :weight, :string

    add_column :imprintables, :base_price, :decimal, precision: 10, scale: 2
    add_column :imprintables, :xxl_price, :decimal, precision: 10, scale: 2
    add_column :imprintables, :xxxl_price, :decimal, precision: 10, scale: 2
    add_column :imprintables, :xxxxl_price, :decimal, precision: 10, scale: 2
    add_column :imprintables, :xxxxxl_price, :decimal, precision: 10, scale: 2
    add_column :imprintables, :xxxxxxl_price, :decimal, precision: 10, scale: 2
  end
end
