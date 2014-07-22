class MakeLineItemsPolymorphic < ActiveRecord::Migration
  def change
    change_table :line_items do |t|
      t.references :line_itemable, polymorphic: true
    end
    remove_column :line_items, :job_id
    add_index :line_items, [:line_itemable_id, :line_itemable_type]
  end
end
