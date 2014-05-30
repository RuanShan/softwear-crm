class Imprintable < ActiveRecord::Base
  validates_presence_of :name, :description

  inject NonDeletable
end
