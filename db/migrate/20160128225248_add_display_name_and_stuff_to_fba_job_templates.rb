class AddDisplayNameAndStuffToFbaJobTemplates < ActiveRecord::Migration
  def change
    add_column :fba_job_templates, :job_name, :string

    create_table :fba_imprint_templates do |t|
      t.integer :print_location_id
      t.integer :fba_job_template_id, index: true
      t.text    :description
      t.integer :artwork_id
    end
  end
end
