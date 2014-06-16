class ImprintMethod < ActiveRecord::Base
  acts_as_paranoid

  has_many :ink_colors, dependent: :destroy
  has_many :print_locations, dependent: :destroy
  accepts_nested_attributes_for :ink_colors, allow_destroy: true
  accepts_nested_attributes_for :print_locations, allow_destroy: true

  validates :name, presence: true
  validates :production_name, uniqueness: {scope: :name}, presence: true

  def canonical_name
    "#{name} (#{production_name})"
  end

end
