class ArtworkRequestArtwork < ActiveRecord::Base
  belongs_to :artwork_request
  belongs_to :artwork
end