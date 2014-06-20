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
      t.decimal :boost
      t.integer :phrase
    end

    create_table :search_filters do |t|
      t.references :filter_holder, polymorphic: true
      t.references :filter_type, polymorphic: true
    end

    create_table :search_filter_groups do |t|
      t.boolean :all
    end

    create_table :search_number_filters do |t|
      field_filter t, :decimal
      t.string :relation, limit: 1
    end

    create_table :search_boolean_filters do |t|
      field_filter t, :boolean
    end

    create_table :search_string_filters do |t|
      field_filter t, :string
    end

    create_table :search_nil_filters do |t|
      field_filter t, nil
    end

    create_table :search_reference_filters do |t|
      field_filter t, :integer
    end

    create_table :search_date_filters do |t|
      field_filter t, :datetime
    end
  end

  private
  def field_filter(t, value_type)
    t.string :field
    t.boolean :not
    t.send value_type, :value unless value_type == nil
  end
end
