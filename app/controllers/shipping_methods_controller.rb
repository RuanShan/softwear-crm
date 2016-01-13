class ShippingMethodsController < InheritedResources::Base
  before_filter :sales_manager_only, only: [:create, :update, :destroy, :edit]
  before_action :set_current_action

  def show
    super do |format|
      format.html { redirect_to edit_shipping_method_path params[:id] }
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to shipping_methods_path }
      failure.html { render action: :edit }
    end
  end

  protected

  def set_current_action
    @current_action = 'shipping_methods'
  end

  private

  def permitted_params
    params.permit(shipping_method: [:name, :tracking_url])
  end
end
