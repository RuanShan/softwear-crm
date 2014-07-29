class ArtworkRequest < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  tracked by_current_user + on_order

  PRIORITIES = {1 => 'High (Rush Job)', 3 => 'Customer Paid For Art', 5 => 'Normal', 7 => 'Low'}

  belongs_to :imprint_method
  belongs_to :print_location
  belongs_to :artist, class_name: User
  belongs_to :salesperson, class_name: User
  has_many :assets, as: :assetable, dependent: :destroy
  has_and_belongs_to_many :ink_colors
  has_and_belongs_to_many :jobs
  has_and_belongs_to_many :artworks
  accepts_nested_attributes_for :assets, allow_destroy: true

  validates :deadline, presence: true
  validates :description, presence: true
  validates :imprint_method, presence: true
  validates :artwork_status, presence: true
  validates :print_location, presence: true
  validates :jobs, presence: true
  validates :ink_colors, presence: true
  validates :salesperson, presence: true
  validates :artist, presence: true
  validates :priority, presence: true

  def imprintable_variant_count
   jobs.map{|j| j.imprintable_variant_count}.inject{|sum,x| sum + x }
  end

  def imprintable_info
    jobs.map{|job| job.imprintable_info}.join(', ')
  end

  def total_quantity
    jobs.map{|j| j.total_quantity}.inject{|sum,x| sum + x }
  end

  def max_print_area(print_location)
    areas = jobs.map{|j| j.max_print_area(print_location)}
    max_width = areas.map{|a| a[0]}.min
    max_height = areas.map{|a| a[1]}.min
    return max_width.to_s + ' in. x ' + max_height.to_s + ' in.'
  end

end
