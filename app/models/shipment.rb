class Shipment < ActiveRecord::Base
  include Popularity
  include Softwear::Auth::BelongsToUser
  include ProductionCounterpart
  include Softwear::Lib::Enqueue

  self.production_class = :polymorphic

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
  enqueue :create_train, queue: 'api'
  after_create :enqueue_create_train, if: :order_in_production?

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

  def order
    shippable_type == 'Order' ? shippable : shippable.try(:order)
  end

  def order_in_production?
    order.try(:production?)
  end

  def create_train
    return if production?
    error = nil

    case shipping_method.name
    when 'Ann Arbor Tees Delivery'
      train = Production::LocalDeliveryTrain.create(
        softwear_crm_id: id,
        order_id: order.softwear_prod_id,
        state:    shipped? ? 'out_for_delivery' : 'pending_packing'
      )
    else
      return if shippable.nil?

      train = Production::ShipmentTrain.create(
        softwear_crm_id: id,
        # NOTE this assumes "Order" and "Job" are named the same in Production and CRM
        shipment_holder_type: shippable_type,
        shipment_holder_id:   shippable.softwear_prod_id,
        state:                shipped? ? 'pending_packing' : 'shipped'
      )
    end

    if train.persisted?
      update_column :softwear_prod_id,   train.id
      update_column :softwear_prod_type, train.class.name
    else
      error = "Failed to create #{train.class.name}: #{train.errors.full_messages.join(', ')}"
    end

    if error && order
      order.issue_warning('Production API', error)
    end
    !!error
  end

  protected

  def assign_proper_status
    self.status = tracking_number.blank? ? 'pending' : 'shipped'
  end
end
