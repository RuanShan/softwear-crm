class ChangeNumberFormatInNameNumber < ActiveRecord::Migration
  def up
    change_column :name_numbers, :number, :string
  end

  def down
    change_column :name_numbers, :number, :integer
  end
end
