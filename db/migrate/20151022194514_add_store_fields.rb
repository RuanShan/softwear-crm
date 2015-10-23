class AddStoreFields < ActiveRecord::Migration
  def change
    add_column :stores, :address_1, :string
    add_column :stores, :address_2, :string
    add_column :stores, :city, :string
    add_column :stores, :state, :string
    add_column :stores, :zipcode, :string
    add_column :stores, :country, :string
    add_column :stores, :phone, :string
    add_column :stores, :sales_email, :string
  end
end
