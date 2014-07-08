class ArtworkRequest < ActiveRecord::Base
  acts_as_paranoid

  PRIORITIES = {1 => 'High (Rush Job)', 3 => 'Customer Paid For Art', 5 => 'Normal', 7 => 'Low'}

  belongs_to :imprint_method
  belongs_to :print_location
  belongs_to :artist, class_name: User
  belongs_to :salesperson, class_name: User
  has_many :assets, as: :assetable, dependent: :destroy
  has_and_belongs_to_many :ink_colors
  has_and_belongs_to_many :jobs
  accepts_nested_attributes_for :assets, allow_destroy: true

  validates :deadline, presence: true
  validates :description, presence: true
  validates :imprint_method_id, presence: true
  validates :artwork_status, presence: true
  validates :print_location_id, presence: true
  validates :job_ids, presence: true
  validates :ink_color_ids, presence: true
  validates :salesperson_id, presence: true
  validates :artist_id, presence: true
  validates :priority, presence: true

  def imprintable_variant_count
   jobs.map{|j| j.imprintable_variant_count}.inject{|sum,x| sum + x }
  end

  def imprintable_info
    jobs.map{|job| job.imprintable_info}.join(', ')
  end

end
