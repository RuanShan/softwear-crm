class CreateArtworkRequestImprints < ActiveRecord::Migration
  def change
    create_table :artwork_request_imprints do |t|
      t.integer :artwork_request_id
      t.integer :imprint_id
    end
  end
end
