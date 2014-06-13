class AddFieldsToImprintable < ActiveRecord::Migration
  def change
    add_column :imprintables, :proofing_template_name, :text
    add_column :imprintables, :material, :string
    add_column :imprintables, :standard_offering, :boolean
  end

  create_table :imprintable_linker_table, id: false do |t|
    t.integer :imprintable_id
    t.integer :coordinate_id
    t.integer :store_id
  end
end
