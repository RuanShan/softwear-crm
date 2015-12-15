class PaymentsController < InheritedResources::Base
  before_filter :initialize_order, only: [:index, :new, :create]

  def create
    super do |success, failure|
      @payment.create_activity(:applied_payment, owner: current_user, recipient: @payment.order) if @payment.valid?

      success.html do
        redirect_to edit_order_path(params[:order_id], anchor: 'payments')
      end
      failure.html { render 'payments/new' }
    end

  rescue Payment::PaymentError => e
    render 'payments/new'
  end

  def update
    super do |format|
      @payment.create_activity(:refunded_payment, owner: current_user, recipient: @payment.order) if @payment.refunded
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

  def initialize_order
    @order = Order.find(params[:order_id])
  end

  def permitted_params
    params.permit(payment: [:amount, :store_id, :salesperson_id, :order_id, :t_company_name, :pp_transaction_id,  
                            :refunded, :refund_reason, :payment_method, :t_name, :t_description, :tf_number,
                            :cc_name, :cc_company, :cc_number, :cc_type, :cc_expiration, :cc_cvc])
  end
end
