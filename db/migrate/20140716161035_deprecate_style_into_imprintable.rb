class DeprecateStyleIntoImprintable < ActiveRecord::Migration
  def up
    add_column :imprintables, :style_name, :string
    add_column :imprintables, :style_catalog_no, :string
    add_column :imprintables, :style_description, :text
    add_column :imprintables, :style_sku, :string
    add_column :imprintables, :retail, :boolean, default: false
    add_column :imprintables, :brand_id, :integer

    execute "UPDATE imprintables i, styles s SET i.style_name = s.name WHERE i.style_id = s.id"
    execute "UPDATE imprintables i, styles s SET i.style_catalog_no = s.catalog_no WHERE i.style_id = s.id"
    execute "UPDATE imprintables i, styles s SET i.style_description = s.description WHERE i.style_id = s.id"
    execute "UPDATE imprintables i, styles s SET i.style_sku = s.sku WHERE i.style_id = s.id"
    execute "UPDATE imprintables i, styles s SET i.retail = s.retail WHERE i.style_id = s.id"
    execute "UPDATE imprintables i, styles s SET i.brand_id = s.brand_id WHERE i.style_id = s.id"

    remove_index :styles, name: :brand_id_ix
    remove_index :styles, name: :index_styles_on_deleted_at
    remove_index :styles, name: :index_styles_on_retail
    drop_table :styles
    remove_column :imprintables, :style_id
  end

  def down

  end
end
