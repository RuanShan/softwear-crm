class RenameProofStatusToState < ActiveRecord::Migration
  def change
    rename_column :proofs, :status, :state
    Proof.where(state: 'approved').update_all(state: :customer_approved)
    Proof.where(state: 'e-mailed customer').update_all(state: :pending_customer_approval)
    Proof.where(state: 'pending').update_all(state: :not_ready)
    Proof.where(state: 'rejected').update_all(state: :customer_rejected)
  end
end
