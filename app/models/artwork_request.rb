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

  belongs_to :artist, class_name: User
  belongs_to :imprint_method
  belongs_to :print_location
  belongs_to :salesperson, class_name: User
  has_many :assets, as: :assetable, dependent: :destroy
  has_many :artworks, through: :artwork_request_artworks
  has_many :artwork_request_artworks
  has_many :artwork_request_ink_colors
  has_many :ink_colors, through: :artwork_request_ink_colors
  has_and_belongs_to_many :jobs

  accepts_nested_attributes_for :assets, allow_destroy: true

  validates :artist, presence: true
  validates :artwork_status, presence: true
  validates :deadline, presence: true
  validates :description, presence: true
  validates :imprint_method, presence: true
  validates :ink_colors, presence: true
  validates :jobs, presence: true
  validates :print_location, presence: true
  validates :priority, presence: true
  validates :salesperson, presence: true

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
end
