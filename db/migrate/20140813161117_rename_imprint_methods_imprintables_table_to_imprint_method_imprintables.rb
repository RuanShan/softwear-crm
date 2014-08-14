class RenameImprintMethodsImprintablesTableToImprintMethodImprintables < ActiveRecord::Migration
  def change
    rename_table :imprint_methods_imprintables, :imprint_method_imprintables
    add_column :imprint_method_imprintables, :id, :primary_key
    add_column :imprint_method_imprintables, :created_at, :datetime
    add_column :imprint_method_imprintables, :updated_at, :datetime
  end
end
