class DiscountsController < InheritedResources::Base
  belongs_to :order, optional: true
  respond_to :js

  ACCEPTED_FORMS = %w(coupon in_store_credit refund)

  def create
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

  def permitted_params
    params.permit(
      discount: [
        :amount, :user_id, :discountable_id, :discountable_type, :reason, :payment_method,
        :applicator_id, :applicator_type, :discount_method
      ]
    )
  end
end
