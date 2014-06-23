class AddRetailBooleanToImprintableAndOptions < ActiveRecord::Migration
  def change
    add_column :colors, :retail, :boolean, default: false
    add_index :colors, :retail
    add_column :styles, :retail, :boolean, default: false
    add_index :styles, :retail
    add_column :sizes, :retail, :boolean, default: false
    add_index :sizes, :retail
    add_column :brands, :retail, :boolean, default: false
    add_index :brands, :retail
  end
end
