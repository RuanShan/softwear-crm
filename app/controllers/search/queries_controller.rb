module Search
  class QueriesController < ApplicationController
    def create
      params.require(:search).permit!

      render text: params.inspect
    end
  end
end