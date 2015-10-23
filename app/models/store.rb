class Store < ActiveRecord::Base
  acts_as_paranoid

  has_many :sample_locations
  has_many :imprintable_stores
  has_many :imprintables, through: :imprintable_stores

  validates_presence_of :name, :address_1, :city, :state, :zipcode, :country, :phone, :sales_email 
  

  def address_array
    [address_1, address_2, "#{city}, #{state} #{zipcode}", country].reject(&:blank?)
  end

end
