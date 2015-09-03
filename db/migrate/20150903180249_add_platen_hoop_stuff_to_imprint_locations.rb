class AddPlatenHoopStuffToImprintLocations < ActiveRecord::Migration
  def change
    add_column :print_locations, :platen_hoop_id, :integer
    add_column :print_locations, :ideal_width, :decimal, precision: 10, scale: 2
    add_column :print_locations, :ideal_height, :decimal, precision: 10, scale: 2
  end
end
