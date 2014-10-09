class CreateLineItemGroups < ActiveRecord::Migration
  def change
    create_table :line_item_groups do |t|
      t.string :name
      t.string :description
      t.references :quote, index: true

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
