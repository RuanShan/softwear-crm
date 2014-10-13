class QuoteRequestsController < InheritedResources::Base
  respond_to :json

  def update
    @quote_request = QuoteRequest.find(params[:id])
    @quote_request.salesperson_id = params[:quote_request][:salesperson_id]
    @quote_request.save
    respond_with @quote_request
  end
end