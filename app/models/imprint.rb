class Imprint < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :job
  belongs_to :print_location
  has_one :imprint_method, through: :print_location

  validates :print_location_id, uniqueness: { scope: :job_id }
  validates_presence_of :job
  validates_presence_of :print_location
end