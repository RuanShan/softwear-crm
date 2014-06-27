module Search
  class QueriesController < ApplicationController
    before_action :permit_params

    def create
      render text: params.inspect
    end

    def search
      if params[:query_id]
        @search = Query.find(params[:query_id]).search
      elsif params[:search]
        @search = QueryBuilder.search(&build_search_proc(params[:search]))
      else
        puts 'your params were useless, however'
      end
      render text: 'text'
    end

  private
    def build_search_proc(search)
      Proc.new do
        search.each do |model, attrs|
          # on Order do
          send(:on, Kernel.const_get(model.camelize)) do
            attrs.each do |num, attr|
              # attr should only have 1 key and 1 value unless num is fulltext
              if num == 'fulltext'
                send(:fulltext, attr)
              else
                # TODO greater_than/less_than
                send(:with, attr.keys.first, attr.values.first)
              end
            end
          end
          puts 'end'
        end
      end
    end

    def permit_params
      params.permit(:search).permit!
      params.permit(:query_id)
    end
  end
end