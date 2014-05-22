class AddSequenceToSizes < ActiveRecord::Migration
  def change
    add_column :sizes, :sequence, :integer
  end
end
