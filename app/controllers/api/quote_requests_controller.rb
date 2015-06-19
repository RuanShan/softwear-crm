module Api
  class QuoteRequestsController < ApiController

    private

    def permitted_params
      params.permit( quote_request: [:name, :email, :date_needed, :description, :source, :phone_number, :approx_quantity] )
    end


  end
end
