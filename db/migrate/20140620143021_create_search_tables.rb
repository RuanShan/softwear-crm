class CreateSearchTables < ActiveRecord::Migration
  def change
    create_table :search_queries do |t|
      t.belongs_to :user
      t.string :name

      t.timestamps
    end

    create_table :search_query_models do |t|
      t.belongs_to :query
      t.string :name
    end

    create_table :search_query_fields do |t|
      t.belongs_to :query_model
      t.string :name
    end

    create_table :search_filters do |t|
      t.references :filter_holder, polymorphic: true
      t.references :filter_type, polymorphic: true
    end

    create_table :search_filter_groups do |t|
      t.boolean :all
    end

    create_table :search_number_filters do |t|
      t.string :field
      t.string :relation, limit: 1
      t.decimal :value
    end

    create_table :search_boolean_filters do |t|
      t.string :field
      t.boolean :value
    end
  end
end
