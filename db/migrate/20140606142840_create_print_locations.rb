class CreatePrintLocations < ActiveRecord::Migration
  def change
    create_table :print_locations do |t|
      t.string :name
      t.integer :imprint_method_id
      t.
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
