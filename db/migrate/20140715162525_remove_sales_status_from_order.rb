class RemoveSalesStatusFromOrder < ActiveRecord::Migration
  def change
    remove_column :orders, :sales_status, :string
  end
end
