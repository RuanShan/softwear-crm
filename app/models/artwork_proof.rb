class ArtworkProof < ActiveRecord::Base
  belongs_to :artwork
  belongs_to :proof
end