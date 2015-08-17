class Shipment < ActiveRecord::Base
  belongs_to :shipping_method
  belongs_to :shippable, polymorphic: true
  belongs_to :shipped_by, class_name: 'User'

  validates :status, presence: true,
    inclusion: { in: ['pending', 'shipped'], message: 'should either be "pending" or "shipped"' }

  before_validation :assign_proper_status

  def shipped?
    status == 'shipped'
  end

  def addresses
    [address_1, address_2, address_3].reject(&:blank?)
  end

  protected

  def assign_proper_status
    if tracking_number
      self.status = 'shipped'
    else
      self.status = 'pending'
    end
  end
end
