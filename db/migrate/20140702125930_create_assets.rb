class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.attachment :file
      t.string :description
      t.references :assetable, polymorphic: true
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
