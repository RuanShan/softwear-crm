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


    def permitted_params
      params.permit(payment: [:amount, :store_id, :salesperson_id, :order_id, :cc_name, :payment_method,
                              :cc_company, :cc_number, :cc_type, :cc_expiration, :cc_cvc])
    end
  end
end
