class AddFreshdeskFlagToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :freshdesk, :boolean
  end
end
