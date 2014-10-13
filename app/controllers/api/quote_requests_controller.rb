module Api
  class QuoteRequestsController < ApiController

    def create
      quote_request = QuoteRequest.new(quote_request_params)
      if quote_request.save
        respond_to do |format|
          format.json { render json: quote_request, status: :created}
        end
      end

    end

    private

    def permitted_attributes
      [:name, :email, :date_needed, :description, :source, :approx_quantity]
    end

    def quote_request_params
      params.permit(:name, :email, :date_needed, :description, :source, :approx_quantity)
    end

  end
end
