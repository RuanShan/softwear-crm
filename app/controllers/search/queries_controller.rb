module Search
  class QueriesController < ApplicationController
    before_action :permit_params

    def create
      render text: params.inspect
    end

  private
    def permit_params
      params.require(:search).permit!
    end
  end
end