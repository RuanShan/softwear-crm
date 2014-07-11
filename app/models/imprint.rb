class Imprint < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  tracked by_current_user + on_order

  belongs_to :job
  belongs_to :print_location
  has_one :imprint_method, through: :print_location

  validates :print_location_id, uniqueness: { scope: :job_id }
  validates_presence_of :job
  validates_presence_of :print_location

  def name
    "#{imprint_method.name} - #{print_location.name}"
  end
end