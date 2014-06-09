class InkColor < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprint_method

  validates :name, uniqueness: {scope: :imprint_method, conditions: -> { where(deleted_at: nil)}}, presence: true

end