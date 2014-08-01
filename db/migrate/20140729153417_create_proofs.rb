class CreateProofs < ActiveRecord::Migration
  def change
    create_table :proofs do |t|
      t.string :status
      t.integer :order_id
      t.datetime :approve_by
      t.datetime :approved_at
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
