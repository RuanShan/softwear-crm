class PaymentsController < InheritedResources::Base
  def create
    super do |format|
      fire_activity(@payment, :applied_payment)
      format.html { redirect_to edit_order_path(params[:order_id], anchor: 'payments') }
    end
  end

  def update
    super do |format|
      fire_activity(@payment, :refunded_payment) if @payment.refunded
      format.html { redirect_to edit_order_path(params[:payment][:order_id], anchor: 'payments') }
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
    params.permit(payment: [:amount, :store_id, :salesperson_id, :order_id,
                            :refunded, :refund_reason, :payment_method])
  end
end
