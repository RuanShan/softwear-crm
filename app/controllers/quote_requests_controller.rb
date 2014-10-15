class QuoteRequestsController < InheritedResources::Base
  respond_to :json, :js

  private

  def permitted_params
    params.permit(
      quote_request: [:status, :salesperson_id]
    )
  end
end