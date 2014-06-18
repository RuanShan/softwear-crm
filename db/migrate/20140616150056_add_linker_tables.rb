class AddLinkerTables < ActiveRecord::Migration
  def change
    create_table :coordinates_imprintables, id: false do |t|
      t.integer :coordinate_id
      t.integer :imprintable_id
    end

    add_index :coordinates_imprintables, [:coordinate_id, :imprintable_id], :name => 'coordinate_imprintable_index'

    create_table :imprintables_stores, id: false do |t|
      t.belongs_to :imprintable
      t.belongs_to :store
    end

    add_index :imprintables_stores, [:imprintable_id, :store_id]

    create_table :imprint_methods_imprintables, id: false do |t|
      t.belongs_to :imprint_method
      t.belongs_to :imprintable
    end

    add_index :imprint_methods_imprintables, [:imprintable_id, :imprint_method_id], :name => 'imprint_method_imprintables_index'
  end
end
