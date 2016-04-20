class DepositsController < InheritedResources::Base
  before_action :sales_manager_only
  before_action :populate_undeposited_payment_drops, except: [:destroy]

  def index
    super do
      @current_action = 'deposits#index'
      @deposits = Deposit.page(params[:page])
    end
  end

  protected

  def set_current_action
    @current_action = 'deposits'
  end

  private

  def permitted_params
    params.permit(deposit: [
                    :depositor_id, :cash_included, :check_included, :difference_reason,
                    :deposit_location, :deposit_id,
                    payment_drop_ids: []
                  ])
  end

  def populate_undeposited_payment_drops
    @undeposited_payment_drops = PaymentDrop.search do
      with(:deposited, false)
    end.results
    @undeposited_cash = PaymentDrop.undeposited_cash
    @undeposited_check = PaymentDrop.undeposited_check
  end

end
