class CreatePlatenHoops < ActiveRecord::Migration
  def change
    create_table :platen_hoops do |t|
      t.string :name
      t.decimal :max_width, precision: 10, scale: 2
      t.decimal :max_height, precision: 10, scale: 2

      t.timestamps null: false
    end
  end
end
