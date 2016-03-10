class PaymentsController < InheritedResources::Base
  include Activity

  before_filter :initialize_order, only: [:index, :new, :create]

  def show
    @order = @payment.order
  end

  def create
    super do |success, failure|
      fire_applied_activity(@payment) if @payment.valid?

      success.html do
        if params[:order_id]
          redirect_to edit_order_path(params[:order_id], anchor: 'payments')
        else
          redirect_to new_payment_path
        end
      end
      failure.html { render params[:order_id] ? 'payments/new' : 'payments/new_retail' }
    end

  rescue Payment::PaymentError => e
    # The error message will be displayed via @payment's payment_method errors
    # (check out views/customer/payments/_credit_card_form.html.erb)
    if params[:order_id]
      render 'payments/new'
    else
      render 'payments/new_retail'
    end
  end

  def update
    super do |format|
      unless @payment.valid?
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
        @target = '#refund-form'
        params[:form] = 'refund'

        render 'discounts/new'
      end
      format.html
    end
  end

  def new
    super do |format|
      @payment = Payment.new(payment_method: params[:payment_method])
      @recent_retail_payments = Payment.retail.order(id: :desc) if @order.nil?

      format.js
      format.html { render 'new_retail' if @order.nil? }
    end
  end

  def undropped
    @payments = Payment.search do
      with(:undropped, true)
      with(:store_id, params[:store_id]) if params[:store_id]
    end.results

    respond_to do |format|
      format.js
    end
  end

  private

  def initialize_order
    @order = Order.find(params[:order_id]) if params[:order_id]
  end

  def permitted_params
    params.permit(payment: [:amount, :store_id, :salesperson_id, :order_id, :t_company_name, :pp_transaction_id,
                            :refunded, :refund_reason, :payment_method, :t_name, :t_description, :tf_number,
                            :cc_name, :cc_company, :cc_number, :cc_type, :cc_expiration, :cc_cvc, :retail_description])
  end
end
