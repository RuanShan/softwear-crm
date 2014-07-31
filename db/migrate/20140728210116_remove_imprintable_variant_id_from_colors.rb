class RemoveImprintableVariantIdFromColors < ActiveRecord::Migration
  def change
    remove_column :colors, :imprintable_variant_id, :integer

    rename_column :users, :firstname, :first_name
    rename_column :users, :lastname, :last_name
  end
end
