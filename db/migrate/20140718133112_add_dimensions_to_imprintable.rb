class AddDimensionsToImprintable < ActiveRecord::Migration
  def up
    add_column :imprintables, :max_imprint_width, :decimal, precision: 8, scale: 2
    add_column :imprintables, :max_imprint_height, :decimal, precision: 8, scale: 2
  end
  def down
    remove_column :imprintables, :max_imprint_width
    remove_column :imprintables, :max_imprint_height
  end
end
