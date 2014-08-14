class ArtworkRequestJob < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :artwork_request
  belongs_to :job

  validates :artwork_request_id, uniqueness: { scope: :job_id }
end
