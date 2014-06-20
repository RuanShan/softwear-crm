class CreateArtworkRequestsJobsJoinTable < ActiveRecord::Migration
  def change
    create_table :artwork_requests_jobs, id: false do |t|
      t.integer :artwork_request_id
      t.integer :job_id
      end
  end
end
