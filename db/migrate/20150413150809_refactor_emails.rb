class RefactorEmails < ActiveRecord::Migration
  def change
    rename_column :emails, :sent_from, :from
    rename_column :emails, :sent_to, :to
    rename_column :emails, :cc_emails, :cc
    add_column :emails, :bcc, :string
  end
end
