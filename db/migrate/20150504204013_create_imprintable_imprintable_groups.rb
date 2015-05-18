class CreateImprintableImprintableGroups < ActiveRecord::Migration
  def change
    create_table :imprintable_imprintable_groups do |t|
      t.integer :imprintable_id
      t.integer :imprintable_group_id
      t.integer :tier
      t.boolean :default
    end
  end
end
