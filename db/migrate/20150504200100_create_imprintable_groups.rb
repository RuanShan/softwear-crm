class CreateImprintableGroups < ActiveRecord::Migration
  def change
    create_table :imprintable_groups do |t|
      t.string :name
    end
  end
end
