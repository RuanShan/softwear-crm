class ShippingMethod < ActiveRecord::Base
  acts_as_paranoid
  
  validates :name, uniqueness: true, presence: true
  # TODO: custom validator?
  validates :tracking_url, format: { with: URI::regexp(%w(http https)), message: 'should be in format http://www.url.com/path' }
end
