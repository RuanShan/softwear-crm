class AddForeignKeyToSize < ActiveRecord::Migration
  def change
    add_column :sizes, :imprintable_variant_id, :integer
  end
end
