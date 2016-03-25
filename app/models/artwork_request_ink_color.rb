class ArtworkRequestInkColor < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :artwork_request
  belongs_to :ink_color

  # validates :ink_color_id, uniqueness: { scope: :artwork_request_id }
end
