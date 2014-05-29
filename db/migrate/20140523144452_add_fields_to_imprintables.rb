class AddFieldsToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :flashable, :boolean
    add_column :imprintables, :special_considerations, :text
    add_column :imprintables, :polyester, :boolean
    add_column :imprintables, :style_id, :integer
    remove_column :imprintables, :name, :text
  end
end
