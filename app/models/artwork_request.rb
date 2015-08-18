class ArtworkRequest < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid

  tracked by_current_user + on_order

  PRIORITIES = {
    1 => 'High (Rush Job)',
    3 => 'Customer Paid For Art',
    5 => 'Normal',
    7 => 'Low'
  }

  STATUSES = [
    'Pending',
    'In Progress',
    'Art Created'
  ]

  has_many :artwork_request_artworks
  has_many :artwork_request_ink_colors
  has_many :artwork_request_imprints
  belongs_to :artist,          class_name: User
  belongs_to :salesperson,     class_name: User
  has_many   :artworks,        through: :artwork_request_artworks
  has_many   :assets,          as: :assetable, dependent: :destroy
  has_many   :ink_colors,      through: :artwork_request_ink_colors
  has_many   :imprints,        through: :artwork_request_imprints
  has_many   :jobs,            through: :artwork_request_imprints
  has_many   :imprint_methods, through: :imprints
  has_many   :print_locations, through: :imprints

  accepts_nested_attributes_for :assets, allow_destroy: true

  validates :artist,         presence: true
  validates :artwork_status, presence: true
  validates :deadline,       presence: true
  validates :description,    presence: true
  validates :ink_colors,     presence: true
  validates :imprints,       presence: true
  validates :priority,       presence: true
  validates :salesperson,    presence: true

  def imprintable_variant_count
    jobs.map(&:imprintable_variant_count).reduce(:+)
  end

  def imprintable_info
    jobs.map(&:imprintable_info).join(', ')
  end

  def max_print_area(print_location)
    areas = jobs.map{ |j| j.max_print_area(print_location) }
    max_width = areas.map(&:first).min
    max_height = areas.map(&:last).min
    "#{max_width.to_s} in. x #{max_height.to_s} in."
  end

  def total_quantity
    jobs.map(&:total_quantity).reduce(:+)
  end

  def print_location
    print_locations.first
  end
  def imprint_method
    imprint_methods.first
  end
end
