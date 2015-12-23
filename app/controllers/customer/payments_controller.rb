module Customer
  class PaymentsController < BaseController
    belongs_to :order, finder: :find_by_customer_key
    defaults route_prefix: 'customer'
    respond_to :js

    def method_for_association_build
      :new
    end

    def create
      super do |success, failure|
        success.js { render 'success' }
        failure.js { render 'failure' }
      end
    rescue Payment::PaymentError => e
      # The error message will be displayed via @payment's payment_method errors
      # (check out views/customer/payments/_credit_card_form.html.erb)
      render 'failure'
    end

    def paypal_express
      @order = Order.find_by_customer_key(params[:order_id])
      @payment = Payment.new(permitted_params[:payment])
      @payment.payment_method = Payment::VALID_PAYMENT_METHODS.key('PayPal')
      @payment.pp_transaction_id = 'not complete'

      unless @payment.valid?
        respond_to do |format|
          format.js { render 'failure' }
        end
        return
      end

      gateway = paypal_express_gateway

      # Item information
      item = {
        description: "Payment for #{@order.store.try(:name) || 'Ann Arbor Tees'} "\
                     "Order ##{@order.id} \"#{@order.name}\"",
        quantity: 1,
        amount: @payment.amount_in_cents
      }
      if Payment.where(order_id: @order.id).exists? || @order.balance_excluding(@payment) - @payment.amount != 0
        item[:name] = "Order ##{@order.id} partial payment"
      else
        item[:name] = "Order ##{@order.id} complete payment"
      end

      # Get purchase token
      response = gateway.setup_purchase(
        @payment.amount_in_cents,

        ip:                   request.remote_ip,
        cancel_return_url:    customer_order_url(@order.customer_key),
        return_url:           paypal_express_success_customer_order_payments_url(
                                @order.customer_key, amount: @payment.amount_in_cents
                              ),
        currency:             'USD',
        allow_guest_checkout: true,
        items:                [item],
        logo_img:             Setting.payment_logo_url,
        max_amount:           (@order.balance_excluding(@payment) * 100).round,
        email:                @order.email,
        no_shipping:          true,
        locale:               'en',
        brand_name:           @order.store.try(:name) || 'Ann Arbor Tees',
        allow_note:           false
      )
      @redirect_uri = gateway.redirect_url_for(response.token)

      respond_to do |format|
        format.html { redirect_to @redirect_uri }
        format.js
      end
    end

    def paypal_express_success
      @order = Order.find_by_customer_key(params[:order_id])

      gateway        = paypal_express_gateway
      express_token  = params[:token]
      payment_amount = params[:amount].to_i

      details = gateway.details_for(express_token)

      response = gateway.purchase(
        payment_amount,
        ip:            request.remote_ip,
        currency_code: 'USD',
        token:         express_token,
        payer_id:      details.payer_id
      )

      # Check for duplicate request
      if response.params['error_codes'].try(:include?, "11607")
        flash[:notice] = "Your payment has already been processed!"
        redirect_to customer_order_path(@order.customer_key) and return
      end

      @payment = Payment.new(
        order_id:       @order.id,
        store_id:       @order.store_id,
        salesperson_id: @order.salesperson_id,
        amount:         payment_amount.to_f / 100.0,
        payment_method: Payment::VALID_PAYMENT_METHODS.key('PayPal')
      )

      if response.success? && (@payment.pp_transaction_id = response.authorization) && @payment.save
        flash[:success] = "Your payment has been processed. Thanks!"
      else
        problems = []
        if !response.success?
          problems << response.message
        end
        if !@payment.errors.empty?
          problems += @payment.errors.full_messages
        end
        if problems.empty?
          problems << "unknown error"
        end

        flash[:error] = "We were unable to process your payment: #{problems.join(', ')}"
      end

      redirect_to customer_order_path(@order.customer_key)
    end

    private

    def paypal_express_gateway
      paypal_auth = {
        login:     Setting.paypal_username,
        password:  Setting.paypal_password,
        signature: Setting.paypal_signature,
        test:      !Rails.env.production?
      }
      ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_auth)
    end

    def permitted_params
      params.permit(payment: [:amount, :store_id, :salesperson_id, :order_id, :cc_name, :payment_method,
                              :cc_company, :cc_number, :cc_type, :cc_expiration, :cc_cvc])
    end
  end
end
