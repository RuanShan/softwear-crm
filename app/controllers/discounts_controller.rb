class DiscountsController < InheritedResources::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  # belongs_to :order, optional: true
  before_filter :grab_order_if_possible
  respond_to :js

  ACCEPTED_FORMS = %w(coupon in_store_credit refund discount)

  def create
    return create_from_in_store_credits if params[:in_store_credit_ids]

    super do |success, failure|
      success.js do
        fire_new_discount_activity(@discount)

        if @discount.applicator_type == 'Refund' && @discount.discountable_type == 'Payment'

          if @discount.credited_for_refund?
            if @discount.discountable.credit_card?
              flash[:notice] = "Refund successful! Customer's card (#{@discount.discountable.cc_number}) "\
                               "was credited #{number_to_currency(@discount.amount)}."
            else
              flash[:notice] = "Refund successful! Customer's PayPal account was credited "\
                              "#{number_to_currency(@discount.amount)}."
            end
          elsif @discount.discountable.transaction_id.blank? || !@discount.discountable.credit_card?
            flash[:notice] = "Successfully created refund. No cards were credited."
          else
            flash[:notice] = nil
            flash[:error] = "Refund noted, but was UNABLE to add funds to the card. The money will have to be "\
                            "refunded manually. For reference: discount id = #{@discount.id}, "\
                            "payment id = #{@discount.discountable_id}."
          end

        else
          flash[:notice] = "#{@discount.discount_type.humanize} was successfully created."
        end
      end
      failure.js { render 'error' }
    end

  rescue Payment::PaymentError => e
    flash[:error] = e.message
    render 'error'
  end

  def update
    super do |success, failure|
      success.html { fire_changed_discount_activity(@discount) }
      success.js   { fire_changed_discount_activity(@discount) }

      failure.html
      failure.js
    end
  end

  def new
    super do |format|
      raise "Invalid form" unless ACCEPTED_FORMS.include? params[:form]
      @target = params[:form] == 'refund' ? '#refund-form' : '#discount-form'
      format.js
    end
  end

  def destroy
    super do |format|
      fire_removed_discount_activity(@discount)
      format.js
    end
  end

  private

  def create_from_in_store_credits
    in_store_credit_ids = params[:in_store_credit_ids].reject(&:blank?)
    if in_store_credit_ids.empty?
      @error_message = "Please provide at least one in-store credit"
      respond_to(&:js) and return
    end

    @discounts = []
    @success = []
    @failure = []

    in_store_credit_ids.each do |in_store_credit_id|
      discount = Discount.create(
        permitted_params[:discount].merge(
          applicator_type: 'InStoreCredit',
          applicator_id: in_store_credit_id
        )
      )
      @failure << discount unless discount.valid?
      @discounts << discount
    end

    if @failure.empty?
      flash[:notice] =
        "Successfully added #{pluralize(@discounts.size, 'in-store credit discount')}."
    end

    respond_to do |format|
      format.js
    end
  end

  def grab_order_if_possible
    if params[:order_id]
      @order = Order.find(params[:order_id])
    elsif @discount
      @discount.order
    elsif @payment
      @payment.order
    end
  end

  def fire_new_discount_activity(discount)
    parameters = { 'refund_amount' => discount.amount }

    if order = discount.order.try(:reload)
      parameters['info'] = {
        type:        discount.discount_type.humanize.downcase,
        amount:      discount.amount,
        order_name:  order.name,
        reason:      discount.reason,
        order_total_before:   order.total_excluding_discounts([discount.id]),
        order_total_after:    order.total,
        order_balance_before: order.balance_excluding_discounts([discount.id]),
        order_balance_after:  order.balance
      }
        .stringify_keys
    end

    discount.create_activity(
      :applied_discount,

      owner: current_user,
      recipient: discount.order,

      parameters: parameters
    )
  end

  def fire_removed_discount_activity(discount)
    parameters = {}

    # Minor hack to make absolutly sure our balance values are correct.
    order = discount.order.reload
    order_discounts = (order.all_discounts + [discount]).uniq
    order.define_singleton_method(:all_discounts) { |*| order_discounts }
    order.recalculate_discount_total

    parameters['info'] = {
      type:       discount.discount_type.humanize.downcase,
      amount:     discount.amount,
      reason:     discount.reason,
      order_name: discount.order.try(:name),
      order_balance_before: order.balance,
      order_balance_after: order.balance_excluding_discounts([discount.id]),
    }

    discount.create_activity(
      :removed_discount,

      owner: current_user,
      recipient: discount.order,

      parameters: parameters
    )
  end

  def fire_changed_discount_activity(discount)
    parameters = {}

    if order = discount.order.try(:reload)
      parameters['info'] = {
        type:          discount.discount_type.humanize.downcase,
        reason:        discount.reason,
        before_amount: discount.amount_was,
        after_amount:  discount.amount,
        order_name:    order.name,
        order_total:   order.total,
        order_balance_before: order.balance_excluding_discounts([discount.id]),
        order_balance_after:  order.balance
      }
        .stringify_keys
    end

    discount.create_activity(
      :adjusted_discount,

      owner: current_user,
      recipient: discount.discountable.order,

      parameters: parameters
    )
  end

  def permitted_params
    params.permit(
      in_store_credit_ids: [],

      discount: [
        :amount, :user_id, :discountable_id, :discountable_type, :reason,
        :applicator_id, :applicator_type, :discount_method, :coupon_code, :transaction_id
      ]
    )
  end
end
