class AddFieldsToTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :plaintext_body, :text
    add_column :email_templates, :to, :string
    add_column :emails, :plaintext_body, :text
  end
end
