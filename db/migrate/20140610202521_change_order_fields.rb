class ChangeOrderFields < ActiveRecord::Migration
  def change
    remove_column :orders, :user_id
    add_column :orders, :salesperson_id, :integer
  end
end
