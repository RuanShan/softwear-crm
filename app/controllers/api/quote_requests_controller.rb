module Api
  class QuoteRequestsController < Softwear::Lib::ApiController

    private

    def permitted_params
      params.permit(
        quote_request: [
          :name, :organization, :email, :date_needed, :description, :source,
          :phone_number, :approx_quantity, :domain, :ip_address, :imprintable_quantities,
          customer_uploads_attributes: [:filename, :url, :id]
        ]
      )
    end


  end
end
