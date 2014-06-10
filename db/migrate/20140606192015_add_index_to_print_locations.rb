class AddIndexToPrintLocations < ActiveRecord::Migration
  def change
    add_index :print_locations, :imprint_method_id
  end
end
