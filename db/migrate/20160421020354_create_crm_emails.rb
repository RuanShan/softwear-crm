class CreateCrmEmails < ActiveRecord::Migration
  def change
    create_table :crm_emails do |t|
      t.string :address, index: true
      t.integer :contact_id
      t.boolean :primary

      t.timestamps null: false
    end
  end
end
