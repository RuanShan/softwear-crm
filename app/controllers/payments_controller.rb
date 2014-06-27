class PaymentsController < InheritedResources::Base

  def create
    super do |format|
      format.html { redirect_to edit_order_path(params[:order_id])+'#payments' }
    end
  end

  def update
    super do |format|
      format.html { redirect_to edit_order_path(params[:payment][:order_id])+'#payments' }

    end
  end

  def edit
    super do |format|
      format.js
      format.html
    end
  end

  def new
    super do |format|
      @payment = Payment.new(payment_method: params[:payment_method])
      @order = Order.find(params[:order_id])
      format.js
    end
  end

  private

  def permitted_params
    params.permit(payment: [:amount,
                            :store_id,
                            :salesperson_id,
                            :order_id,
                            :refunded,
                            :refund_reason,
                            :payment_method])
  end
end
