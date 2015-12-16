class PaymentsController < InheritedResources::Base
  before_filter :initialize_order, only: [:index, :new, :create]

  def create
    super do |success, failure|
      fire_applied_activity(@payment) if @payment.valid?

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
      if @payment.valid?
        fire_refund_activity(@payment) if @payment.refunded?
      else
        flash[:error] = @payment.errors.full_messages.join(', ')
      end

      format.html { redirect_to edit_order_path(params[:payment][:order_id], anchor: 'payments') }
    end

  rescue Payment::PaymentError => e
    flash[:error] = e.message
    redirect_to edit_order_path(params[:payment][:order_id], anchor: 'payments')
  end

  def edit
    super do |format|
      format.js do
        @order = @payment.order
        @discount = Discount.new(
          applicator_type: 'refund',
          discountable:    @payment,
          discount_method: 'RefundPayment',
          transaction_id:  @payment.cc_transaction
        )
        @scroll = true
        params[:form] = 'refund'

        render 'discounts/new'
      end
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

  def fire_applied_activity(payment)
    parameters = {}

    if payment.credit_card?
      if payment.cc_transaction.blank?
        parameters['transaction'] = "No actual transaction made"
      elsif payment.cc_transaction == 'ERROR'
        parameters['transaction'] = "Transaction error"
      else
        parameters['transaction'] = "Payflow transaction PNRef: #{payment.cc_transaction}"
      end
    end

    payment.create_activity(
      :applied_payment,

      owner:     current_user,
      recipient: payment.order,

      parameters: parameters
    )
  end

  def fire_refund_activity(payment)
    payment.create_activity(
      :refunded_payment,

      owner: current_user,
      recipient: payment.order,

      parameters: { 'refund_amount' => payment.refund_amount }
    )
  end

  def initialize_order
    @order = Order.find(params[:order_id])
  end

  def permitted_params
    params.permit(payment: [:amount, :store_id, :salesperson_id, :order_id, :t_company_name, :pp_transaction_id,
                            :refunded, :refund_reason, :payment_method, :t_name, :t_description, :tf_number,
                            :cc_name, :cc_company, :cc_number, :cc_type, :cc_expiration, :cc_cvc, :refund_amount])
  end
end
