class Imprint < ActiveRecord::Base
  include TrackingHelpers

  attr_reader :name_number_expected

  acts_as_paranoid

  tracked by_current_user + on_order

  belongs_to :job
  belongs_to :print_location
  has_many :name_numbers
  has_one :imprint_method, through: :print_location

  validates :job, presence: true
  validates :print_location, presence: true, uniqueness: { scope: :job_id }

  scope :name_number, -> { joins(:imprint_method).where(imprint_methods: { name: 'Name/Number' }) }

  def name
    "#{imprint_method.try(:name) || 'n\a'} - #{print_location.try(:name) || 'n\a'}"
  end
end
