class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :subject
      t.text :body
      t.string :sent_to
      t.string :sent_from
      t.string :cc_emails
      t.references :emailable, polymorphic: true
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
