class Shipment < ActiveRecord::Base
  include Popularity
  include Softwear::Auth::BelongsToUser

  rates_popularity_of :shipping_method

  belongs_to :shipping_method
  belongs_to :shippable, polymorphic: true
  belongs_to_user_called :shipped_by

  validates :status, presence: true,
    inclusion: { in: ['pending', 'shipped'], message: 'should either be "pending" or "shipped"' }
  
  validates :shippable, presence: true, if: :persisted?
  validates :name, :address_1, :city, :state, :zipcode, presence: true

  before_validation :assign_proper_status
  after_save do
    shippable.try(:check_if_shipped!)
  end

  def shipped?
    status == 'shipped'
  end

  def addresses
    [address_1, address_2, address_3].reject(&:blank?)
  end

  def complete_address
    [name, company, attn, address_1, address_2, address_3, "#{city}, #{state} #{zipcode}", country].reject(&:blank?)
  end

  def time_in_transit
    super || 0.0
  end

  protected

  def assign_proper_status
    self.status = tracking_number.blank? ? 'pending' : 'shipped'
  end
end
