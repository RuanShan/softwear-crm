class AddCollapsedToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :collapsed, :boolean
  end
end
