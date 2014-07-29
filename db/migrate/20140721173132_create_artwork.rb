class CreateArtwork < ActiveRecord::Migration
  def change
    create_table :artworks do |t|
      t.string :name
      t.string :description
      t.integer :artist_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
