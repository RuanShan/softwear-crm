class AddMarketplaceStuffToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :water_resistance_level, :string
    add_column :imprintables, :sleeve_type, :string
    add_column :imprintables, :sleeve_length, :string
    add_column :imprintables, :neck_style, :string
    add_column :imprintables, :neck_size, :string
    add_column :imprintables, :fabric_type, :string
    add_column :imprintables, :is_stain_resistant, :boolean
    add_column :imprintables, :fit_type, :string
    add_column :imprintables, :fabric_wash, :string
    add_column :imprintables, :department_name, :string
    add_column :imprintables, :chest_size, :string
    add_column :imprintables, :package_height, :decimal
    add_column :imprintables, :package_width, :decimal
    add_column :imprintables, :package_length, :decimal
  end
end
