class CreateSearchSortFilters < ActiveRecord::Migration
  def change
    create_table :search_sort_filters do |t|
      field_filter t, :string
    end
  end

  private
  def field_filter(t, *args)
    value_type = args.first
    options = args.last.is_a?(Hash) ? args.last : {}

    t.string :field
    t.boolean :negate
    t.send value_type, :value, options unless value_type == nil
  end
end
