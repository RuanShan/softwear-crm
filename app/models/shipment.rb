class Shipment < ActiveRecord::Base
  belongs_to :shipping_method
  belongs_to :shippable, polymorphic: true
  belongs_to :shipped_by, class_name: 'User'

  validates :status, presence: true,
    inclusion: { in: ['pending', 'shipped'], message: 'should either be "pending" or "shipped"' }
  
  validates :shippable, presence: true
  validates :name, :address_1, :city, :state, :zipcode, presence: true

  before_validation :assign_proper_status

  def shipped?
    status == 'shipped'
  end

  def addresses
    [address_1, address_2, address_3].reject(&:blank?)
  end

  def complete_address
    [name, company, attn, address_1, address_2, address_3, "#{city}, #{state} #{zipcode}", country].reject(&:blank?)
  end

  protected

  def assign_proper_status
    unless tracking_number.blank?
      self.status = 'shipped'
    else
      self.status = 'pending'
    end
  end
end
