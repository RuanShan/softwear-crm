class AddRetailFlagToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :retail_description, :text
  end
end
