class AddJobIdToProofs < ActiveRecord::Migration
  def change
    add_column :proofs, :job_id, :integer
  end
end
