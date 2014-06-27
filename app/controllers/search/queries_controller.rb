module Search
  class QueriesController < ApplicationController
    before_action :permit_params

    def create
      render text: params.inspect
    end

    def search
      puts 'im happening'
      if params[:query_id]
        puts "yes #{params[:query_id]}"
        @search = Query.find(params[:query_id]).search
      elsif params[:search]
        # build it damn
      else
        puts 'your params were useless, however'
      end
      render text: 'text'
    end

  private
    def permit_params
      params.permit(:search).permit!
      params.permit(:query_id)
    end
  end
end