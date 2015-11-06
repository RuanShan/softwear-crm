class AddCustomerPaidForArtworkToArtworkRequest < ActiveRecord::Migration
  def change
    add_column :artwork_requests, :amount_paid_for_artwork, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
