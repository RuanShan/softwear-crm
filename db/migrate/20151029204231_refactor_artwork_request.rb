class RefactorArtworkRequest < ActiveRecord::Migration
  def change
    rename_column :artwork_requests, :artwork_status, :state
    add_column :artwork_requests, :reorder, :boolean, index: true
    add_column :artwork_requests, :approved_by_id, :integer, index: true
    add_column :artwork_requests, :exact_or_approximate, :string, index: true
  end
end
