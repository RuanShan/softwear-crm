class ArtworkRequestInkColor < ActiveRecord::Base
  belongs_to :artwork_request
  belongs_to :ink_color
end