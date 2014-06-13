class Imprint < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :job
  belongs_to :print_location
  has_one :imprint_method, through: :print_location
end