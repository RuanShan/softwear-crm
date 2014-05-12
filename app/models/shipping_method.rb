class ShippingMethod < ActiveRecord::Base
  #include NonDeleteable
  validates_uniqueness_of :name
  validates :tracking_url, :format => URI::regexp(%w(http https))

end
