class CreatePrintLocations < ActiveRecord::Migration
  def change
    create_table :print_locations do |t|
      t.string :name
      t.integer :imprint_method_id
      t.decimal :max_height, precision: 8, scale: 2
      t.decimal :max_width, precision: 8, scale: 2
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
