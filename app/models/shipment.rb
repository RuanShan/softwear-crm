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
  validates :name, :address_1, :city, :state, :zipcode, :time_in_transit, presence: true
  validates :time_in_transit,  numericality: { greater_than: 0 }

  before_validation :assign_proper_status
  after_save do
    shippable.try(:check_if_shipped!)
  end
  enqueue :create_train, queue: 'api'
  after_create :enqueue_create_train, if: :order_in_production?

  def tracking_url
    shipping_method.tracking_url.gsub(':tracking_number', "#{tracking_number}")
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

  def order
    shippable_type == 'Order' ? shippable : shippable.try(:order)
  end

  def order_in_production?
    order.try(:production?)
  end

  def carrier
    case shipping_method.name
    when /^UPS/     then 'UPS'
    when /^USPS/    then 'USPS'
    when /Freight$/ then 'Freight'
    else
      nil
    end
  end

  def service
    if /^US?PS\s+(?<s>.+)$/ =~ shipping_method.name
      s
    else
      shipping_method
    end
  end

  def create_train
    return if production?
    return if Rails.env.development?
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

      train_state = 'pending_packing'
      if shipped?
        train_state = 'pending_shipment'
        if [carrier, service, tracking_number, shipped_at, shipped_by_id].none?(&:blank)
          train_state = 'shipped'
        end
      end

      train = Production::ShipmentTrain.create(
        softwear_crm_id: id,
        shipment_holder_type: shippable_type,
        shipment_holder_id:   shippable.softwear_prod_id,
        state:                train_state,
        tracking:             tracking_number,
        shipped_at:           shipped_at,
        carrier:              carrier,
        service:              service,
        shipped_by_id:        shipped_by_id
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
  rescue RuntimeError => _
  end
end
