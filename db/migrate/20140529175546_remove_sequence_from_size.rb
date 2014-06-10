class RemoveSequenceFromSize < ActiveRecord::Migration
  def change
    remove_column :sizes, :sequence, :integer
  end
end
