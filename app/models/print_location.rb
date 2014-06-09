class PrintLocation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprint_method

  validates :name, uniqueness: {scope: :imprint_method, conditions: -> { where(deleted_at: nil)}}, presence: true
  validates :max_height, numericality: true, presence: true
  validates :max_width, numericality: true, presence: true

end
