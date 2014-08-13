class Store < ActiveRecord::Base
  acts_as_paranoid

  has_many :sample_locations
  has_many :imprintable_stores
  has_many :imprintables, through: :imprintable_stores

  validates_presence_of :name
end
