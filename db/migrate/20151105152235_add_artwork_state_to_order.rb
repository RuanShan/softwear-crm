class AddArtworkStateToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :artwork_state, :string, index: true
    Order.all.each do |o|
      if o.missing_artwork_requests?
        o.update_column(:artwork_state, :pending_artwork_requests)
      elsif !o.missing_artwork_requests? && o.missing_proofs?
        o.update_column(:artwork_state, :pending_artwork) 
      elsif !o.missing_proofs?
         o.update_column(:artwork_state, :pending_proofs) 
      elsif o.proofs_pending_approval?
        o.update_column(:artwork_state, :pending_proof_approval)
      elsif !o.proofs_pending_approval?
        o.update_column(:artwork_state, :in_production) 
      else
        o.update_column(:artwor_state, :pending_artwork_requests)
      end
    end
  end
end
