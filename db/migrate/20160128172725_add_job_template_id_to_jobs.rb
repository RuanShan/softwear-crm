class AddJobTemplateIdToJobs < ActiveRecord::Migration
  def change
    add_reference :jobs, :fba_job_template, index: true, foreign_key: true
  end
end
