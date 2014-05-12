class ShippingMethodsController < InheritedResources::Base

  def update
    super do |format|
      format.html { redirect_to shipping_methods_path }
    end
  end

  def show
    super do |format|
      format.html { redirect_to edit_shipping_method_path params[:id] }
    end
  end

  private

  def permitted_params
    params.permit(shipping_method: [:name, :tracking_url])
  end
end
