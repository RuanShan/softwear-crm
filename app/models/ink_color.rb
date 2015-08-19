class InkColor < ActiveRecord::Base
  acts_as_paranoid

=begin
  # BEFORE MIGRATION
  belongs_to :imprint_method
  has_many :artwork_request_ink_colors
  has_many :artwork_requests, through: :artwork_request_ink_colors
=end

  # AFTER MIGRATION
  has_many :imprint_method_ink_colors
  has_many :imprint_methods, through: :imprint_method_ink_colors
  has_many :artwork_request_ink_colors
  has_many :artwork_requests, through: :artwork_request_ink_colors

  validates :name, presence: true, uniqueness: true
end
