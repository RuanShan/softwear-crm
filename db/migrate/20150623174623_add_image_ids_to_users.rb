class AddImageIdsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_picture_id, :integer
    add_column :users, :signature_id, :integer
  end
end
