module Customer
  class OrdersController < Customer::BaseController
    defaults finder: :find_by_customer_key

    def update
      super do |success, failure|
        success.js do
          if @order.invoice_state == 'pending' && !@order.invoice_reject_reason.blank?

            fire_invoice_rejected_activity(@order)
            OrderMailer.invoice_rejected(@order, edit_order_url(@order)).deliver

            render 'invoice_rejected'

          elsif @order.invoice_state == 'approved'

            fire_invoice_approved_activity(@order)
            OrderMailer.invoice_approved(@order, edit_order_url(@order)).deliver

            render 'invoice_approved'

          else
            render 'invoice_need_reason'
          end
        end

        failure.js { render 'invoice_error' }
      end
    end

    def edit
      super(&:js)
    end

    private

    def fire_invoice_rejected_activity(order)
      order.create_activity(
        :rejected_invoice,

        recipient: order.salesperson,
        parameters: { reason: order.invoice_reject_reason }
      )
    end

    def fire_invoice_approved_activity(order)
      order.create_activity(
        :approved_invoice,
        recipient: order.salesperson,
      )
    end

    def order_params
      params.require(:order).permit(:invoice_status, :rejection_reason)
    end
  end
end

