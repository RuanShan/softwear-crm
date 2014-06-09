class CreateImprintMethods < ActiveRecord::Migration
  def change
    create_table :imprint_methods do |t|
      t.string :name
      t.string :production_name
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
