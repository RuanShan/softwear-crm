module PaymentsController::Activity
  def fire_applied_activity(payment)
    parameters = {}

    if payment.credit_card?
      if payment.cc_transaction.blank?
        parameters['transaction'] = "No actual transaction made."
      elsif payment.cc_transaction == 'ERROR'
        parameters['transaction'] = "Transaction error."
      else
        parameters['transaction'] = "Payflow transaction PNRef: #{payment.cc_transaction}."
      end

    elsif payment.paypal?
      unless payment.pp_transaction_id.blank?
        parameters['transaction'] = "PayPal transaction ID: #{payment.pp_transaction_id}."
      end

    elsif payment.cash?
      parameters['transaction'] = "Transaction made in cash."
    end


    if payment.order
      payment.order.reload
      parameters['info'] = {
        amount:      payment.amount,
        order_name:  payment.order.name,
        order_total: payment.order.total,
        order_balance_before: payment.order.balance_excluding(payment.id),
        order_balance_after:  payment.order.balance
      }
        .stringify_keys
    else
      parameters['retail'] = {
        description: payment.retail_description,
        amount: payment.amount
      }
        .stringify_keys
    end

    payment.create_activity(
      :applied_payment,

      owner:     payment.salesperson,
      recipient: payment.order,

      parameters: parameters
    )
  end
end
