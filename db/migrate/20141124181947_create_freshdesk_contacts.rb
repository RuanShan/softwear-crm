class CreateFreshdeskContacts < ActiveRecord::Migration
  def change
    create_table :freshdesk_local_contacts do |t|
      t.string :name
      t.integer :freshdesk_id
      t.string :email
      t.timestamps
    end
  end
end
