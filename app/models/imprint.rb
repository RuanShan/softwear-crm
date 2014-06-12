class Imprint < ActiveRecord::Base
	belongs_to :imprint_method
  has_many :print_locations
  
end