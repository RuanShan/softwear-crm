class AddForeignKeyToColor < ActiveRecord::Migration
  def change
    add_column :colors, :imprintable_variant_id, :integer
  end
end
