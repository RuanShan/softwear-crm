class RenameArtworkRequestsJobsTableToArtworkRequestJobs < ActiveRecord::Migration
  def change
    rename_table :artwork_requests_jobs, :artwork_request_jobs
    add_column :artwork_request_jobs, :id, :primary_key
    add_column :artwork_request_jobs, :created_at, :datetime
    add_column :artwork_request_jobs, :updated_at, :datetime
  end
end
