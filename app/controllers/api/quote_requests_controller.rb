module Api
  class QuoteRequestsController < ApiController
    private

    def permitted_attributes
      [:name, :email, :date_needed, :description, :source, :approx_quantity]
    end
  end
end
