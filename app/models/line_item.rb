class LineItem < ActiveRecord::Base
  belongs_to :job

  validates_presence_of :name

  inject NonDeletable
end