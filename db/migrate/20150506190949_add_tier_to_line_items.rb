class AddTierToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :tier, :integer
  end
end
