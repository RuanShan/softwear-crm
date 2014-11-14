class QuoteRequestsController < InheritedResources::Base
  respond_to :json, :js

  before_action :set_current_action

  def index
    super do
      @quote_requests = QuoteRequest.all.page(params[:page])
    end
  end

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


