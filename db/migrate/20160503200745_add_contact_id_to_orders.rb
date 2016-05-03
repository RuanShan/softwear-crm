class AddContactIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :contact_id, :integer
    add_index :orders, :contact_id

    rename_column :orders, :email, :deprecated_email
    rename_column :orders, :firstname, :deprecated_firstname
    rename_column :orders, :lastname, :deprecated_lastname
    rename_column :orders, :twitter, :deprecated_twitter
    rename_column :orders, :phone_number, :deprecated_phone_number
  end
end
