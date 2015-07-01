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
    session[:docked] << quote_request.to_dock
    redirect_to root_path, notice: "Docked Quote Request #{quote_request.id}"
  end

  def create_freshdesk_ticket
    @quote_request = QuoteRequest.find(params[:quote_request_id])
    begin
      @quote_request.create_freshdesk_ticket
      flash[:success] = "Freshdesk ticket created!"
    rescue StandardError => e
      flash[:alert] = "Failed to create freshdesk ticket. See warning for details."
    end

    redirect_to quote_request_path(@quote_request)
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


