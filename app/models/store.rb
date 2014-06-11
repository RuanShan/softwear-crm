class Store < ActiveRecord::Base
  validates_presence_of :name

  acts_as_paranoid

end
