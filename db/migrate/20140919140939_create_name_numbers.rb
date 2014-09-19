class CreateNameNumbers < ActiveRecord::Migration
  def change
    create_table :name_numbers do |t|
      t.string :name
      t.integer :number
    end

    remove_column :imprints, :name_number
    add_column :imprints, :name_number_id, :integer
  end
end
