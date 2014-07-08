class ChangeImprintableCategoryCagetoryToName < ActiveRecord::Migration
  def change
    rename_column :imprintable_categories, :category, :name
  end
end
