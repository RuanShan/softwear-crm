class ImprintMethod < ActiveRecord::Base
  acts_as_paranoid

  has_many :ink_colors, dependent: :destroy
  has_many :print_locations, dependent: :destroy
  accepts_nested_attributes_for :ink_colors, allow_destroy: true
  accepts_nested_attributes_for :print_locations, allow_destroy: true

  validates_presence_of :name, :production_name
  validates_uniqueness_of :production_name, { scope: :name }

end
