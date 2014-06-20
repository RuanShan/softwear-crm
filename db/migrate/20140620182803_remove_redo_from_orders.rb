class RemoveRedoFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :is_redo
    remove_column :orders, :redo_reason
  end
end
