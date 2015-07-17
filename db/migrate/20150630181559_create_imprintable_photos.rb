class CreateImprintablePhotos < ActiveRecord::Migration
  def change
    create_table :imprintable_photos do |t|
      t.integer :color_id
      t.integer :imprintable_id
      t.boolean :default

      t.timestamps null: false
    end
  end
end
