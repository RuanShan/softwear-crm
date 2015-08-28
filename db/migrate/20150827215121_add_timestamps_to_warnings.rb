class AddTimestampsToWarnings < ActiveRecord::Migration
  def change
    add_column :warnings, :created_at, :datetime
    add_column :warnings, :updated_at, :datetime
  end
end
