class ChangeLineItemableBackToJob < ActiveRecord::Migration
  def change
    remove_column :line_items, :line_itemable_type, :string
    rename_column :line_items, :line_itemable_id, :job_id
  end
end
