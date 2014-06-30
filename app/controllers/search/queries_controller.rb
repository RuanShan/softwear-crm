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
        session[:last_search] = params[:search]
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
      ### Helper functions are defined in here as lambdas, since the context
      ### within the returned proc will not be this controller.

      # Helper function to get with/without depending on whether or
      # not a field is negated.
      with_or_without = -> (metadata) { metadata.include?('negate') ? :without : :with }
      # Get any_of/all_of depending on metadata
      any_or_all_of = -> (metadata) { metadata.include?('any_of') ? :any_of : :all_of }
      # Get a post-funtion for a filter call.
      greater_or_less_than = -> (metadata) do
        metadata.each { |m| case m; when 'greater_than', 'less_than'; return m; end }
        nil
      end

      default_fulltext = search['fulltext']

      # Turn hash search data into function calls
      process_attrs = -> (attrs) do
        Proc.new do
          applied_fulltext = false
          attrs.each do |num, attr|
            # num will either be 'fulltext' or a number.
            # If it's a number, attr is a hash with { fieldname=>fieldvalue, posssiblemetadata=>array }
            # TODO boost fields, dang.
            if num == 'fulltext'
              send(:fulltext, attr)
              applied_fulltext = true
            else
              # puts attr.inspect

              # Grab a field name and possible metadata
              field_name = nil; field_value = nil
              metadata = []
              group_attrs = nil
              attr.each do |key, value|
                case key
                when '_metadata'
                  metadata = value
                when '_group'
                  group_attrs = value
                else
                  field_name = key
                  field_value = value
                end
              end
              
              if group_attrs
                send(any_or_all_of.call(metadata), &process_attrs.call(group_attrs))
              else
                with = with_or_without.call(metadata)
                post_func = greater_or_less_than.call(metadata)

                # The call is structured differently if it is a relative comparison
                if post_func
                  send(with, field_name).send(post_func, field_value)
                else
                  send(with, field_name, field_value)
                end
              end
            end
          end
          # Apply default fulltext if we didn't run into a model-specific fulltext (and if there is a default set)
          fulltext(default_fulltext) unless applied_fulltext || !default_fulltext
        end
      end

      # The actual returned proc
      Proc.new do
        search.each do |model, attrs|
          next if model == 'fulltext'
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

          on actual_model, &process_attrs.call(attrs)
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