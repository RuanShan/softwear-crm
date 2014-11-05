class QuoteRequestsController < InheritedResources::Base
  respond_to :json, :js

  before_action :set_current_action

  private

  def permitted_params
    params.permit(
      quote_request: [:status, :salesperson_id]
    )
  end

  def set_current_action
    @current_action = 'quote_requests'
  end
end
