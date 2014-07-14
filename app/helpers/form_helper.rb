module FormHelper
  def add_class(options, *values)
    options[:class] ||= ''
    values.each do |v|
      options[:class] << ' ' unless options[:class].empty?
      options[:class] << v
      options.merge!(@common_attrs) unless @common_attrs.nil?
    end
  end

  # Just like form_for except for searches on models.
  # Rather than passing a specific resource, you pass a class, i.e. Order.
  # Many of the same functions in the Rails form builder are available
  # on the search form builder.
  # 
  # Theoretically this could be used to save a search query to the 
  # database as well if you pass a query object after the model class.
  def search_form_for(model, *args, &block)
    query = if args.first.is_a? Search::Query
      args.first
    else nil end
    options = if args.last.is_a? Hash
      args.last
    else {} end

    builder = SearchFormBuilder.new(
      model, query, self, @current_user, session[:last_search])

    output = capture(builder, &block)
    action = if query
      options[:method] ||= 'PUT'
      search_query_path(query)
    else
      options[:method] ||= 'GET'
      search_path
    end
    options[:id] ||= "#{model.name.underscore}_search"
    form_tag(action, options) { output }
  end

  # Gets a select box for the current user's saved queries on the given
  # model class.
  def select_search_queries(model, options={})
    return unless @current_user
    add_class options, 'form-control', 'search-query-select'
    options[:id] = "select_query_for_#{model.name.underscore}"
    select_options = content_tag(:option, "#{model.name.humanize} queries...", value: 'nil')

    current = if session[:last_search] =~ /\d/
      session[:last_search].to_i
    end

    @current_user.search_queries.joins(:query_models).
      where(search_query_models: { name: model.name }).each do |query|
        
        select_options.send :original_concat, content_tag(:option,
          query.name, value: query.id, selected: query.id == current)
    end

    form_tag search_path, method: 'GET' do
      select_tag('id', select_options, options)
    end
  end

  def search_field(options={}, &block)
    add_class options, 'form-control', 'search'

    form_tag search_path, method: 'GET', role: 'form' do
      is_textarea = options.delete :textarea
      func = is_textarea ? :text_area_tag : :text_field_tag

      send(func, 'q', '', options) + (block_given? ? capture(&block) : '')
    end
  end


  def inline_field_tag(object, method, default_or_options={}, options={})
    default = nil
    if default_or_options.is_a? Hash
      options = default_or_options
      default = method.to_s.gsub(/_/, ' ')
    else
      default = default_or_options
    end
    add_class options, 'inline-field'
    # TODO change resource- to data-resource for validity
    options.merge! ({
          :contenteditable   => true,
          'resource-name'    => object.class.name.underscore,
          'resource-plural'  => object.class.name.underscore.pluralize,
          'resource-id'      => object.id,
          'resource-method'  => method
        })
    content = object.send(method) || default
    content_tag(:span, content, options)
  end
end