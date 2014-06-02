class RemoveFieldsFromImprintables < ActiveRecord::Migration
  def change
    remove_column :imprintables, :catalog_number, :string
    remove_column :imprintables, :description, :string
  end
end
