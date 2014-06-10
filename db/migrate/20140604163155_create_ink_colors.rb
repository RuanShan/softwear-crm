class CreateInkColors < ActiveRecord::Migration
  def change
    create_table :ink_colors do |t|
      t.string :name
      t.integer :imprint_method_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
