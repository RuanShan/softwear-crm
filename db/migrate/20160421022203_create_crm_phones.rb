class CreateCrmPhones < ActiveRecord::Migration
  def change
    create_table :crm_phones do |t|
      t.string :number, index: true
      t.string :extension
      t.integer :contact_id, index: true
      t.boolean :primary

      t.timestamps null: false
    end
  end
end
