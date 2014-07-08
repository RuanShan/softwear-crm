class RemoveProductionNameFromImprintMethods < ActiveRecord::Migration
  def change
    remove_column :imprint_methods, :production_name
  end
end
