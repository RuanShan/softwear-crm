class AddNameNumberBoolToImprintMethodsAndImprints < ActiveRecord::Migration
  def change
    add_column :imprint_methods, :name_number, :boolean
    add_column :imprints,        :name_number, :boolean
  end
end
