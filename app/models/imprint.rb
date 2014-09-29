class Imprint < ActiveRecord::Base
  include TrackingHelpers

  attr_reader :name_number_expected

  acts_as_paranoid

  tracked by_current_user + on_order

  belongs_to :job
  belongs_to :print_location
  belongs_to :name_number
  has_one :imprint_method, through: :print_location
  has_one :order, through: :job

  validates :job, presence: true
  validates :print_location, presence: true, uniqueness: { scope: :job_id }

  def name
    "#{imprint_method.name} - #{print_location.name}"
  end
end
