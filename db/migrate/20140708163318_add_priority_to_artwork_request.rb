class AddPriorityToArtworkRequest < ActiveRecord::Migration
  def change
    add_column :artwork_requests, :priority, :string
  end
end
