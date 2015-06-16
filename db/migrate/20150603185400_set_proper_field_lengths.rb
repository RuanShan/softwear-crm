class SetProperFieldLengths < ActiveRecord::Migration
  def change
    change_column :comments, :title, :string, limit: 140
  end
end
