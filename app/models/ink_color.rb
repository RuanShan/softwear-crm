class InkColor < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprint_method
  has_and_belongs_to_many :artwork_requests

  validates :name, presence: true, uniqueness: { scope: :imprint_method }
end
