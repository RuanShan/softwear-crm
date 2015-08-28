class CreateWarningEmails < ActiveRecord::Migration
  def change
    create_table :warning_emails do |t|
      t.string :model
      t.decimal :minutes, precision: 10, scale: 2
      t.string :recipient
      t.string :url
    end
  end
end
