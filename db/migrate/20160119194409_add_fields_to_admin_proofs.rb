class AddFieldsToAdminProofs < ActiveRecord::Migration
  def change
    add_column :admin_proofs, :name, :string
    add_column :admin_proofs, :description, :text
  end
end
