class ArtworkRequestInkColor < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :artwork_request
  belongs_to :ink_color

  validates :artwork_request_id, uniqueness: { scope: :ink_color_id }
end
