class PaymentDropsController < InheritedResources::Base
  before_action :populate_salesperson_id, only: :create
  before_action :set_current_action
  before_action :populate_undropped_payments

  def index
    super do
      @current_action = 'payment_drops#index'
      @payment_drops = PaymentDrop.page(params[:page])
    end
  end

  protected

  def set_current_action
    @current_action = 'payment_drops'
  end

  private

  def populate_undropped_payments
    @undropped_payments = Payment.search do
      with(:undropped, true)
      with(:store_id, params[:store_id]) if params[:store_id]
    end.results
  end

  def populate_salesperson_id
    if params[:payment_drop]
      params[:payment_drop][:salesperson_id] = current_user.id
    end
  end

  def permitted_params
    params.permit(payment_drop: [
                      :salesperson_id, :store_id, :cash_included, :difference_reason,
                      payment_ids: []
                ])
  end
end
