class PlatenHoop < ActiveRecord::Base
  validates :name, uniqueness: true
  validates :max_width, :max_height, presence: true

  has_many :print_locations
end
