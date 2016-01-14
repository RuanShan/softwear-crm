class InStoreCreditsController < InheritedResources::Base
  before_action :set_current_action
  before_action :format_dates, only: [:create, :update]

  def search
    @in_store_credits = InStoreCredit.search do
      fulltext params[:q]

      with :used, false
      with(:valid_until).greater_than Time.now
      without :id, params[:exclude] if params[:exclude]
    end
      .results

    respond_to do |format|
      format.js
    end
  end

  def new
    super do |format|
      if params[:order_id]
        @target = '#refund-form'
        @form_partial = 'in_store_credits/order_form'
        format.js { render 'discounts/new' }
      end
      format.html
    end
  end

  def create
    super do |success, failure|
      if @in_store_credit.order_id
        @job = @in_store_credit.job

        success.html { redirect_to edit_order_path(@in_store_credit.order_id) }
        success.js { render 'jobs/create' }

        failure.html do
          flash[:error] = @in_store_credit.errors.full_messages.join(', ')
          redirect_to edit_order_path(@in_store_credit.order_id)
        end
        failure.js do
          # FIXME Kinda sloppy reuse of code here
          @discount = @in_store_credit
          render 'discounts/error'
        end
      else
        success.html
        failure.html
      end
    end
  end

  protected

  def set_current_action
    @current_action = 'in_store_credit'
  end

  private

  def permitted_params
    params.permit(
      in_store_credit: [
        :name, :customer_first_name, :customer_last_name, :customer_email,
        :amount, :description, :user_id, :valid_until, :order_id
      ]
    )
  end

  def format_dates
    return if params[:in_store_credit].nil?

    unless params[:in_store_credit][:valid_until].nil?
      valid_until = params[:in_store_credit][:valid_until]
      params[:in_store_credit][:valid_until] = format_time(valid_until)
    end
  end
end
