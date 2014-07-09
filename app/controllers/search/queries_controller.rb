module Search
  class QueriesController < ApplicationController
    before_action :permit_params
    skip_before_filter :verify_authenticity_token

    def create
      begin
        @query = QueryBuilder.build(query_params[:name], &build_search_proc(params[:search])).query
        @query.update_attributes query_params
        raise "Failed to create search query" unless @query.save
        flash[:success] = "Successfully saved search query!"
      rescue Exception => e
        flash[:error] = "#{e.message}. #{@query.errors.full_messages.join(', ') if @query}"
      end
      if params[:target_path]
        redirect_to params[:target_path]
      else
        render text: 'nice!'
      end
    end

    def update
      @query = Query.find query_id
      @query.update_attributes query_params
      QueryBuilder.build(@query, &build_search_proc(params[:search]))
      if @query.save
        render text: 'ok'
      else
        render text: 'not ok'
      end
    end

    def destroy
      @query = Query.find query_id
      @query.destroy
      respond_to do |format|
        format.json { render json: {result: @query.destroyed? ? 'success' : 'failure'} }
        format.html { render text: 'hi' }
      end
    end

    def search
      if query_id
        begin
          @query = Query.includes(query_models: [:filter, :query_fields]).find(query_id)
          session[:last_search] = query_id
          @search = @query.search page: params[:page]
        rescue ActiveRecord::RecordNotFound
          return render text: '404!' 
        end
      elsif params[:search]
        session[:last_search] = params[:search]
        @search = QueryBuilder.search({page: params[:page]}, &build_search_proc(params[:search]))
      else
        puts 'your params were useless, however'
      end

      models = models_of params[:search] || @query
      case models.count
      when 1
        models = models.first.underscore.pluralize
        instance_variable_set "@#{models}", @search.first.results
        destination = Rails.root.join('app', 'views', models, 'index.html.erb').to_s
        render destination
      else
        render text: "Implement multi-model search results view plz!"
      end
    end

  private
    def build_search_proc(search)
      ### Helper functions are defined in here as lambdas, since the context
      ### within the returned proc will not be this controller.

      # Get any_of/all_of depending on metadata
      any_or_all_of = -> (metadata) { metadata.include?('any_of') ? :any_of : :all_of }
      # Get comparator for number filters
      comparator_for = -> (metadata) do
        metadata.each do |m|
          case m
            when 'greater_than'; return '>'
            when 'less_than'; return '<'
          end
        end
        '='
      end

      default_fulltext = search['fulltext']

      # Turn hash search data into function calls
      process_attrs = -> (attrs, model, base_scope) do
        Proc.new do
          applied_fulltext = false
          attrs.each do |num, attr|
            # num will either be 'fulltext' or a number.
            # If it's a number, attr is a hash with { fieldname=>fieldvalue, posssiblemetadata=>array }
            # TODO boost fields, dang.
            if num == 'fulltext'
              fulltext attr
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

              # If the value is nil or empty, it means we don't even want to filter on it.
              next if field_value == 'nil' || (!group_attrs && field_value.nil?) || (field_value.respond_to?(:empty?) && field_value.empty?)

              # If we're in a group, recurse!
              if group_attrs
                send(any_or_all_of.call(metadata), &process_attrs.call(group_attrs, model, base_scope))
              else
                # Get the search field we're working with, and its associated filter type.
                field = Field[model, field_name]
                filter_type = FilterType.of field

                # The field value will be a string; this will convert it into the proper
                # Ruby type if possible.
                field_value = filter_type.assure_value(field_value)

                args = { field: field_name, value: field_value, negate: metadata.include?('negate') }
                args.merge!(comparator: comparator_for.call(metadata)) if filter_type.uses_comparator?

                filter_type.new(args).apply(self, base_scope)
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
            raise SearchException.new "#{actual_model} is not a model."
          end

          unless actual_model.respond_to? :searchable
            raise SearchException.new "#{actual_model.inspect} is not searchable."
          end

          on actual_model do
            instance_eval(&process_attrs.call(attrs, actual_model, self))
          end
        end
      end
    end

    def models_of(search_params)
      if search_params.is_a? Hash
        search_params.keys.reject { |k| k == 'fulltext' }
      else
        search_params.models.map(&:name)
      end
    end

    def permit_params
      params.permit(:search).permit!
      params.permit(:id)
      params.permit(:page)
      params.permit(:target_path)
      params.permit(:user_id)
    end

    def query_params
      begin
        params.require(:query).permit(:name, :user_id)
      rescue
        {}
      end
    end

    def query_id
      params[:id]
    end
  end
end