class AddForeignKeys < ActiveRecord::Migration
  def change
    add_column :users, :store_id, :integer
    add_column :orders, :store_id, :integer
  end
end
