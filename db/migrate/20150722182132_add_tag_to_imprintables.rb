class AddTagToImprintables < ActiveRecord::Migration
  def change
    add_column :imprintables, :tag, :string, :default => 'Not Specified'
  end
end
