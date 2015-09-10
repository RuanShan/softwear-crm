class DiscountsController < InheritedResources::Base
  include ActionView::Helpers::TextHelper

  belongs_to :order, optional: true
  respond_to :js

  ACCEPTED_FORMS = %w(coupon in_store_credit refund)

  def create
    return create_from_in_store_credits if params[:in_store_credit_ids]

    super do |success, failure|
      success.js
      failure.js { render 'error' }
    end
  end

  def new
    super do |format|
      raise "Invalid form" unless ACCEPTED_FORMS.include? params[:form]
      format.js
    end
  end

  private

  def create_from_in_store_credits
    @discounts = []
    @success = []
    @failure = []

    params[:in_store_credit_ids].each do |in_store_credit_id|
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
