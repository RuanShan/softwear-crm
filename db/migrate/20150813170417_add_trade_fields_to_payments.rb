class AddTradeFieldsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :t_name, :string
    add_column :payments, :t_company_name, :string
    add_column :payments, :tf_number, :string
    add_column :payments, :t_description, :text
  end
end
