class ArtworkRequest < ActiveRecord::Base
  acts_as_paranoid

  # belongs_to :user
  belongs_to :imprint_method
  belongs_to :print_location
  belongs_to :artist, class_name: User
  belongs_to :salesperson, class_name: User
  # has_many :assets
  has_and_belongs_to_many :ink_colors
  has_and_belongs_to_many :jobs

  validates :deadline, presence: true
  validates :description, presence: true
  validates :imprint_method_id, presence: true
  validates :artwork_status, presence: true
  validates :print_location_id, presence: true
  validates :job_ids, presence: true
  validates :ink_color_ids, presence: true
  validates :salesperson_id, presence: true
  validates :artist_id, presence: true
  # validates :assets, associated: true


  def total_line_items
    # sum of job.imprintable_variant_count
  end


end
