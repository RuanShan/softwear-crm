class Imprint < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid
  tracked by_current_user + on_order

  belongs_to :job
  belongs_to :print_location
  has_one :imprint_method, through: :print_location
  has_one :order, through: :job

  validates :print_location, uniqueness: { scope: :job_id }, presence: true
  validates :job, presence: true

  def name
    "#{imprint_method.name} - #{print_location.name}"
  end
end
