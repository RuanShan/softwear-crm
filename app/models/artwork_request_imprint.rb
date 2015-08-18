class ArtworkRequestImprint < ActiveRecord::Base
  belongs_to :artwork_request
  belongs_to :imprint
  has_one :job, through: :imprint

  validates :artwork_request_id, uniqueness: { scope: :imprint_id }
end
