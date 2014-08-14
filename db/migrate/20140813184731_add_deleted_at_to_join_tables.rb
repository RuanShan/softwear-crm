class AddDeletedAtToJoinTables < ActiveRecord::Migration
  def change
    add_column :artwork_request_artworks, :deleted_at, :datetime
    add_column :artwork_request_ink_colors, :deleted_at, :datetime
    add_column :artwork_request_jobs, :deleted_at, :datetime
    add_column :artwork_proofs, :deleted_at, :datetime
    add_column :imprintable_stores, :deleted_at, :datetime
    add_column :imprint_method_imprintables, :deleted_at, :datetime
  end
end
