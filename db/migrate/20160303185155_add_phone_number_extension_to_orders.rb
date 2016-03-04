class AddPhoneNumberExtensionToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :phone_number_extension, :string
  end
end
