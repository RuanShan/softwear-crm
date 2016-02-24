class AddSoftwearProdIdToArtworkRequests < ActiveRecord::Migration
  def change
    add_column :artwork_requests, :softwear_prod_id, :integer
  end
end
