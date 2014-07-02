class InkColor < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprint_method
  has_and_belongs_to_many :artwork_requests

  validates :name, uniqueness: {scope: :imprint_method, conditions: -> { where(deleted_at: nil)}}, presence: true

end