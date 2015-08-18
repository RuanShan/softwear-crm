class ShipmentsController < InheritedResources::Base
  belongs_to :order, :job, optional: true, polymorphic: true
  before_filter :format_shipped_at, only: [:create, :update]

  def create
    super do |format|
      format.js
    end
  end

  def update
    super do |format|
      format.js
    end
  end

  def edit
    super do |format|
      format.js
    end
  end

  def destroy
    super do |format|
      format.js
    end
  end

  protected

  def format_shipped_at
    unless params[:shipment].nil? || params[:shipment][:shipped_at].nil?
      shipped_at = params[:shipment][:shipped_at]
      params[:shipment][:shipped_at] = format_time(shipped_at)
    end
  end

  def permitted_params
    params.permit(
      :order_id,
      shipment: [
        :shipping_method_id, :shipped_by_id, :shippable_id, :shippable_type,
        :shipping_cost, :shipped_at, :tracking_number, :state, :name, :company,
        :attn, :address_1, :address_2, :address_3, :city, :state, :zipcode, :country,
      ]
    )
  end
end
