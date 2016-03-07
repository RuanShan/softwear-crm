class PaymentDropsController < InheritedResources::Base
  before_filter :sales_manager_only
  before_action :populate_salesperson_id, only: :create
  before_action :set_current_action
  before_action :populate_undropped_payments, except: [:edit]
  layout 'no_overlay', only: [:show]

  def index
    super do
      @current_action = 'payment_drops#index'
      @payment_drops = PaymentDrop.page(params[:page])
    end
  end

  def edit
    super do
      populate_undropped_payments
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
      if @payment_drop
        with(:store_id, @payment_drop.store_id)
      elsif params[:store_id]
        with(:store_id, params[:store_id]) if params[:store_id]
      end
    end.results
  end

  def populate_salesperson_id
    if params[:payment_drop]
      params[:payment_drop][:salesperson_id] = current_user.id
    end
  end

  def permitted_params
    params.permit(payment_drop: [
                      :salesperson_id, :store_id, :cash_included, :check_included, :difference_reason,
                      payment_ids: []
                ])
  end

end
