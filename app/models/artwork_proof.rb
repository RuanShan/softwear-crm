class ArtworkProof < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :artwork
  belongs_to :proof

  validates :artwork_id, uniqueness: { scope: :proof_id }
end
