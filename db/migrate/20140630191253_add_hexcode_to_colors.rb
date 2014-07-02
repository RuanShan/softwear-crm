class AddHexcodeToColors < ActiveRecord::Migration
  def change
    add_column :colors, :hexcode, :string

    create_table :imprintable_categories do |t|
      t.string :category
      t.integer :imprintable_id
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
