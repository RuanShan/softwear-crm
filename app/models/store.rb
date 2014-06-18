class Store < ActiveRecord::Base
  acts_as_paranoid

  has_many :sample_locations
  has_and_belongs_to_many :imprintables

  validates_presence_of :name

end
