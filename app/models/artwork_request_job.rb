class ArtworkRequestJob < ActiveRecord::Base
  belongs_to :artwork_request
  belongs_to :job
end