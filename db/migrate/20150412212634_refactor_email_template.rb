class RefactorEmailTemplate < ActiveRecord::Migration
  def change
    remove_column :email_templates, :quote_id, :integer
    add_column :email_templates, :template_type, :string
    add_column :email_templates, :name, :string
    remove_column :email_templates, :template, :text
  end
end
