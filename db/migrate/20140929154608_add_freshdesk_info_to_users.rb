class AddFreshdeskInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :freshdesk_email, :string
    add_column :users, :freshdesk_password, :string
    add_column :users, :encrypted_freshdesk_password, :string
  end
end
