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

  protected

  def set_current_action
    @current_action = 'in_store_credit'
  end

  private

  def permitted_params
    params.permit(
      in_store_credit: [
        :name, :customer_first_name, :customer_last_name, :customer_email,
        :amount, :description, :user_id, :valid_until
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
