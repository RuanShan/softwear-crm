class ArtworkRequest < ActiveRecord::Base

  belongs_to :user
  belongs_to :imprint_method
  belongs_to :print_location
  has_and_belongs_to_many :ink_colors, dependent: :destroy
  has_and_belongs_to_many :jobs, dependent: :destroy
  accepts_nested_attributes_for :ink_colors, allow_destroy: true
  accepts_nested_attributes_for :jobs, allow_destroy: true

end
