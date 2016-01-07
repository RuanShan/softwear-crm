class ShippingMethod < ActiveRecord::Base
  include Popularity

  acts_as_paranoid
  popularity_rated_from :shipments

  has_many :shipments
  
  validates :name, uniqueness: true, presence: true
  # TODO: custom validator?
  validates :tracking_url, format: { with: URI::regexp(%w(http https)), message: 'should be in format http://www.url.com/path' }
end
