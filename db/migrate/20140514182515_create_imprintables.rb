class CreateImprintables < ActiveRecord::Migration
  def change
    create_table :imprintables do |t|
      t.string :name
      t.string :catalog_number
      t.text :description

      t.timestamps
    end
  end
end
