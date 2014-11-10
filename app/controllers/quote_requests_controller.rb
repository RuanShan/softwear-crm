class QuoteRequestsController < InheritedResources::Base
  respond_to :json, :js

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
end