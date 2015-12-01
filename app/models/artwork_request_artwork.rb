class ArtworkRequestArtwork < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :artwork_request, touch: true
  belongs_to :artwork

  validates :artwork_request_id, uniqueness: { scope: :artwork_id }

  after_create :transition_artwork_request

  def transition_artwork_request
    artwork_request.artwork_added unless ( artwork_request.nil? || artwork_request.can_artwork_added? )
  end

end
