module Search
  class QueriesController < ApplicationController
    before_action :permit_params

    def create
      @query = QueryBuilder.build(&build_search_proc(params[:search])).query
      render text: 'nice!'
    end

    def update
      @query = Query.find params[:id]
      QueryBuilder.build(@query, &build_search_proc(params[:search]))
      render text: 'ok'
    end

    def destroy
      @query = Query.find params[:id]
      @query.destroy
      render text: 'cool'
    end

    def search
      if params[:query_id]
        @search = Query.find(params[:query_id]).search
      elsif params[:search]
        @search = QueryBuilder.search(&build_search_proc(params[:search]))
      else
        puts 'your params were useless, however'
      end
      render text: if params[:search]
                     params[:search].inspect
                   else
                     @search.inspect
                   end
    end

  private
    def build_search_proc(search)
      Proc.new do
        search.each do |model, attrs|
          actual_model = case model
            when Symbol, String
              Kernel.const_get(model.camelize)
            when Class
              model
            end

          unless actual_model < ActiveRecord::Base
            raise "#{actual_model} is not a model."
          end

          unless actual_model.respond_to? :searchable
            raise "#{actual_model.inspect} is not searchable."
          end

          # on Order do
          send(:on, actual_model) do
            attrs.each do |num, attr|
              # attr should only have 1 key and 1 value unless num is fulltext
              if num == 'fulltext'
                send(:fulltext, attr)
              else
                # TODO greater_than/less_than
                puts attr.inspect
                send(:with, attr.keys.first, attr.values.first)
              end
            end
          end
        end
      end
    end

    def permit_params
      params.permit(:search).permit!
      params.permit(:query_id)
      params.permit(:id)
    end
  end
end