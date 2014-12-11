class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :subject
      t.string :from
      t.string :bcc
      t.string :cc
      t.integer :quote_id
      t.text :body
      t.text :template

      t.datetime :deleted_at
    end

  end
end
