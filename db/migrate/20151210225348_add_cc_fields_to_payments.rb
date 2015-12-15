class AddCcFieldsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :cc_name, :string
    add_column :payments, :cc_company, :string
    add_column :payments, :cc_number, :string
    add_column :payments, :cc_type, :string
    add_column :payments, :cc_expiration, :string
    add_column :payments, :cc_cvc, :string
  end
end
