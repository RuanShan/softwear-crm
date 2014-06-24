class PaymentsController < InheritedResources::Base

  def create
    super do |format|
      format.html { redirect_to edit_order_path(params[:order_id])+'#payments' }
    end
  end

  private

  def permitted_params
    params.permit(payment: [:amount, :store_id, :salesperson_id, :order_id])
  end
end
