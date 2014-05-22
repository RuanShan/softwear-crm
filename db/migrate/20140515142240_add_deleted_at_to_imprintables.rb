class AddDeletedAtToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :deleted_at, :datetime
  end
end
