class RefactorArtworkRequest < ActiveRecord::Migration
  def change
    add_column :artwork_requests, :state, :string
    add_column :artwork_requests, :reorder, :boolean, index: true
    add_column :artwork_requests, :approved_by_id, :integer, index: true
    add_column :artwork_requests, :exact_recreation, :boolean, index: true
    ArtworkRequest.where(artwork_status: 'Pending', artist: nil).each{|ar| ar.update_column(:state, :unassigned) }
    ArtworkRequest.where(artwork_status: 'Pending').where.not(artist: nil).each{|ar| ar.update_column(:state, :pending_artwork) }
    ArtworkRequest.where(artwork_status: 'Art Created').each{|ar| ar.update_columns(state: :manager_approved, approved_by_id: 2) }
    remove_column :artwork_requests, :artwork_status, :string
  end
end
