class ArtworkRequestArtwork < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :artwork_request, touch: true
  belongs_to :artwork

  validates :artwork_request_id, uniqueness: { scope: :artwork_id }

end
