class InkColor < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprint_method
  has_many :artwork_request_ink_colors
  has_many :artwork_requests, through: :artwork_request_ink_colors

  validates :name, presence: true, uniqueness: { scope: :imprint_method }
end
