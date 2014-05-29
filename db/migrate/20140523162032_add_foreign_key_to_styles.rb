class AddForeignKeyToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :brand_id, :integer
  end
end
