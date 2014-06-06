class PrintLocation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprint_method

  validates_presence_of :name, :max_height, :max_width
  validates_uniqueness_of :name, { scope: :imprint_method, conditions: -> { where(deleted_at: nil)} }

end
