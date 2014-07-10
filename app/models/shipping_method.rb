class ShippingMethod < ActiveRecord::Base
  include PublicActivity::Model

  acts_as_paranoid
  tracked
  
  validates :name, uniqueness: true, presence: true
  validates :tracking_url, format: {with: URI::regexp(%w(http https)), message: 'should be in format http://www.url.com/path'}
end
