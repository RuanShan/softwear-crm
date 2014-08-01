class CreateArtworksProofsJoinTable < ActiveRecord::Migration
  def change
    create_table :artworks_proofs, id: false do |t|
      t.integer :artwork_id
      t.integer :proof_id
    end
  end
end
