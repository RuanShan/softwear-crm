class QuoteRequestsController < InheritedResources::Base
  respond_to :json, :js

  before_action :set_current_action

  def index
    super do
      @quote_requests = QuoteRequest.of_interest.page(params[:page])
    end
  end

  def dock
    quote_request = QuoteRequest.find(params[:quote_request_id])
    unless session[:docked].is_a?(Array)
      session[:docked] = []
    end
    session[:docked] << %i(id name approx_quantity description date_needed)
                          .map{|a| { a => quote_request[a] } }
                          .reduce({}, :merge)
    redirect_to root_path, notice: "Docked Quote Request #{quote_request.id}"
  end

  private

  def permitted_params
    params.permit(
      :id, quote_request: [:status, :salesperson_id, :reason, :freshdesk_contact_id]
    )
  end

  def set_current_action
    @current_action = 'quote_requests'
  end
end


