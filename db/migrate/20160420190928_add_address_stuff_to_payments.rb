class AddAddressStuffToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :address1, :string
    add_column :payments, :city, :string
    add_column :payments, :state, :string
    add_column :payments, :country, :string
    add_column :payments, :zipcode, :string
  end
end
