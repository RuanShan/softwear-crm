class CreateArtworkRequestsArtworksJoinTable < ActiveRecord::Migration
  def change
    create_table :artwork_requests_artworks, id: false do |t|
      t.integer :artwork_request_id
      t.integer :artwork_id
    end
  end
end
