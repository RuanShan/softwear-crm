class RenameArtworksProofsTableToArtworkProofs < ActiveRecord::Migration
  def change
    rename_table :artworks_proofs, :artwork_proofs
    add_column :artwork_proofs, :id, :primary_key
    add_column :artwork_proofs, :created_at, :datetime
    add_column :artwork_proofs, :updated_at, :datetime
  end
end
