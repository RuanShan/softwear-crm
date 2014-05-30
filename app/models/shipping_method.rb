class ShippingMethod < ActiveRecord::Base

  validates :name, uniqueness: true, presence: true
  validates :tracking_url, format: {with: URI::regexp(%w(http https)), message: 'should be in format http://www.url.com/path'}

  inject NonDeletable
end
