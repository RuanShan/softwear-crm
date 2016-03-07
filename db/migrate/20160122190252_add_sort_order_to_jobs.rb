class AddSortOrderToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :sort_order, :integer
  end
end
