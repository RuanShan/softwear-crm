class AddDescriptionToImprintableGroups < ActiveRecord::Migration
  def change
    add_column :imprintable_groups, :description, :text
  end
end
