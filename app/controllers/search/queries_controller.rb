module Search
  class QueriesController < ApplicationController
    # Funkify gives us auto_currying, which is used to keep our context
    # in a clean manner when dealing with Sunspot DSL procs.
    include Funkify

    before_action :permit_params
    skip_before_filter :verify_authenticity_token

    def create
      begin
        @query = QueryBuilder.build(
          query_params[:name],
          &compose_search_proc(params[:search])
        )
          .query
        
        @query.update_attributes query_params

        raise "Failed to create search query" unless @query.valid?
        flash[:success] = "Successfully saved search query!"
      rescue StandardError => e
        flash[:error] = 
          "#{e.message}. #{@query.errors.full_messages.join(', ') if @query}"
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
      QueryBuilder.build(@query, &compose_search_proc(params[:search]))

      # #update is currently not actually used
      if @query.valid?
        render text: 'ok'
      else
        render text: 'not ok'
      end
    end

    def destroy
      @query = Query.find query_id
      @query.destroy

      respond_to do |format|
        format.json do
          render json: { result: @query.destroyed? ? 'success' : 'failure' }
        end
        format.html { render text: 'hi' }
      end
    end

    def search
      if query_id
        begin
          assign_search_from_query
        rescue ActiveRecord::RecordNotFound
          return render text: '404!'
        end
      elsif params[:search]
        assign_search_from_data
      elsif params[:q]
        assign_search_from_fulltext
      else
        return render text: "Can't search without a query of some sort!"
      end

      models = models_of params[:search] || @query

      respond_to do |format|
        [:html, :js, :json].each do |ext|
          format.send(ext) { render_for(models, ext) }
        end
      end
    end

    private

    def assign_search_from_query
      @query = Query.includes(
        query_models: [:filter, :query_fields]
      )
        .find(query_id)

      session[:last_search] = query_id
      @search = @query.search page: params[:page]
    end

    def assign_search_from_data
      session[:last_search] = params[:search]
      @search = QueryBuilder.search(
        { page: params[:page] },
        &compose_search_proc(params[:search])
      )
    end

    def assign_search_from_fulltext
      text = params[:q]

      @search = QueryBuilder.search page: params[:page] do
        on(:all) { fulltext text }
      end
    end

    def render_for(models, format)
      if models.size == 1
        plural = models.first.underscore.pluralize
        locals = permitted_locals_for(models.first)

        instance_variable_set "@#{plural}", @search.first.results
        destination = 
          Rails
          .root
          .join('app', 'views', plural, "index.#{format}.erb").to_s
        
        render destination, locals: locals
      else
        render text: "Implement multi-model search results view plz!"
      end
    end

    # This is step 1 to transforming hash filter data to valid
    # Sunspot DSL procs.
    def compose_search_proc(search)
      default_fulltext = search['fulltext']

      pass_self_to do |context|
        search.each do |model, fields|
          next if model == 'fulltext'

          actual_model = actual_model_of model

          process_fields(model, fields, context, context)
          context.on(
            actual_model,
            # Here we are calling initial_process with one less parameter
            # than it's defined to take. Because it is auto curried, 
            # rather than raising an error, it returns a proc that will
            # take one parameter, and use it as the remaining argument.
            &pass_self_to(initial_process(default_fulltext, model, fields))
            # And of course, pass_self_to returns a proc that will complete
            # the argument requirement for initial_process when executed.
          )
        end
      end
    end

    # This adds the proper group block to the context, and bounces
    # execution back to process_fields to apply the contents of the
    # group.
    def process_group(model, base_scope, field_hash, context)
      group_func = metadata?(field_hash, 'any_of') ? :any_of : :all_of

      context.send(
        group_func,
        &pass_self_to(
          process_fields(nil, model, base_scope, field_hash['_group'])
        )
      )
    end

    # This is the star of the show. It parses the hash, constructs the
    # filter, and applies it with the given contexts.
    def apply_filter(model, base_scope, field_hash, context)
      field_name, string_value = extract_field(field_hash)
      metadata = field_hash['_metadata']

      return if field_is_nil? string_value

      field       = Field[model, field_name]
      filter_type = FilterType.of field
      field_value = filter_type.assure_value(string_value)

      filter = {
        field:      field_name,
        value:      field_value,
        negate:     metadata.try(:include?, 'negate'),
      }
      if filter_type.uses_comparator?
        filter[:comparator] = comparator_for(metadata)
      end

      filter_type.new(filter).apply(context, base_scope)
    end

    # This decides whether the hash is asking for a filter, a group, or
    # a specific fulltext.
    def process_fields(default_fulltext, model, base_scope, fields, context)
      applied_fulltext = false

      fields.each do |num, field|
        if num == 'fulltext'
          base_scope.fulltext field
          applied_fulltext = true
          next
        end

        args = [model, base_scope, field, context]
        field['_group'] ? process_group(*args) : apply_filter(*args)
      end

      if !applied_fulltext && default_fulltext
        context.fulltext default_fulltext
      end
    end

    # At first we only have one context, which is both the base and the current
    def initial_process(default_fulltext, model, fields, context)
      process_fields(default_fulltext, model, context, fields, context)
    end

    auto_curry :process_fields, :initial_process

    def comparator_for(metadata)
      return if metadata.nil?

      metadata.each do |m|
        case m
          when 'greater_than' then return '>'
          when 'less_than'    then return '<'
        end
      end
      '='
    end

    def extract_field(field)
      field.each do |name, value|
        return name, value unless name.starts_with?('_')
      end
      nil
    end

    def metadata?(fields, key)
      fields['_metadata'].try(:include?, key)
    end

    def field_is_nil?(field_value)
      field_value.nil?     ||
      field_value == 'nil' || 
      (field_value.respond_to?(:empty?) && field_value.empty?)
    end

    # Using this with currying, we never have to perform logic
    # inside of another context (i.e. Sunspot's DSL blocks).
    # 
    # The tiny proc returned by this method is the only thing that actually
    # happens inside the augmented context.
    def pass_self_to(passed = nil, &block)
      proc { (passed || block).call(self) }
    end

    def actual_model_of(model)
      case model
      when Symbol, String
        Kernel.const_get(model.camelize)
      when Class
        model
      end
    end

    def models_of(search_params)
      case search_params
        when Hash
          search_params.keys.reject { |k| k == 'fulltext' }
        when Query
          search_params.models.map(&:name)
        else
          Models.all.map(&:name)
      end
    end

    def permit_params
      params.permit(:search).permit!
      params.permit(:id, :page, :target_path, :user_id, :q, :locals)
    end

    def permitted_locals_for(model)
      return {} unless params[:locals]

      controller_name = "#{model.pluralize.camelize}Controller"
      controller = Kernel.const_get controller_name

      if controller.respond_to?(:permitted_search_locals)
        locals = {}

        permitted = controller.permitted_search_locals
        params.permit(locals: permitted)

        params[:locals].each do |k,v|
          unless permitted.include?(k.to_sym)
            unpermitted_local_error(k, controller_name)
          end
          locals[k.to_sym] = v
        end

        if controller.respond_to?(:transform_search_locals)
          controller.transform_search_locals locals
        else
          locals
        end
      end
    end

    def unpermitted_local_error(name, controller_name)
      unless Rails.env.production?
        raise %{
          Unpermitted local variable passed through search: #{name}.
          If you actually want to pass it, please include :#{name} in 
          the array returned by #{controller_name}.permitted_search_locals
          (Currently #{Kernel.const_get(controller_name)
            .permitted_search_locals.inspect})
        }
      end
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