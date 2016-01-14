class CreateFbaJobTemplates < ActiveRecord::Migration
  def change
    create_table :fba_job_templates do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :fba_job_template_imprints do |t|
      t.references :fba_job_template, index: true, foreign_key: true
      t.references :imprint, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
