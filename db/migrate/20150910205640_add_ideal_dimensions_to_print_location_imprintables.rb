class AddIdealDimensionsToPrintLocationImprintables < ActiveRecord::Migration
  def change
    add_column :print_location_imprintables, :ideal_imprint_width, :decimal, precision: 10, scale: 2
    add_column :print_location_imprintables, :ideal_imprint_height, :decimal, precision: 10, scale: 2
    add_column :print_location_imprintables, :platen_hoop_id, :integer

    remove_column :print_locations, :ideal_width, :decimal
    remove_column :print_locations, :ideal_height, :decimal
    remove_column :print_locations, :platen_hoop_id, :integer
  end
end
