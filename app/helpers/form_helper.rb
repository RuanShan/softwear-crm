module FormHelper
  def add_class(options, *values)
    options[:class] ||= ''

    values.each do |v|
      options[:class] << ' ' unless options[:class].empty?
      options[:class] << v
      options.merge!(@common_attrs) unless @common_attrs.nil?
    end
  end

  def last_search
    session[:last_search]
  end

  def assure_search_value(filter)
    assure = filter.filter_type_type.constantize.method(:assure_value)
    assure.call(filter.value)
  end

  def last_sort_ordering(model_name, field)
    return nil if last_search.nil?

    model_name = model_name.downcase

    if last_search.is_a?(Hash)
      o = last_search[model_name].try(:[], 'order_by')
      if o.blank?
        nil
      else
        o[1] if o[0].to_sym == field
      end

    elsif last_search.is_a?(String) && last_search =~ /\d+/
      query = Search::Query.find_by(id: last_search)
      return if query.nil?

      model = query.query_models.find_by(name: model_name)
      # Just gonna assume that the filter is a group...
      find_sort_filter = lambda do |filter|
        case filter.filter_type
        when Search::FilterGroup
          filter.filter_type.filters.each { |f| find_sort_filter.(f) }
        when Search::SortFilter
          return filter.filter_type
        end
      end

      sort_filter = model.filter.filters.where(filter_type_type: 'Search::SortFilter').first

      if !sort_filter.nil? && sort_filter.field.to_sym == field.to_sym
        sort_filter.value
      end
    end
  end

  def next_sort_ordering(last_ordering)
    case last_ordering
    when nil    then 'desc'
    when 'desc' then 'asc'
    when 'asc'  then nil
    else
      nil
    end
  end

  # Gives you a th tag with a caret for sorting ascending or descending. This
  # assumes that there is also a search form from #search_form_for somewhere
  # on the page.
  def sorted_th(field, text = nil, options = {})
    if text.is_a?(Hash)
      options = text
    else
      text ||= field.to_s.titleize
    end
    model_name = options[:model_name] || (defined?(collection) && collection.first.try(:class).try(:name))
    if model_name.nil?
      Rails.logger.error "No model name specified for sorted_th."
      return content_tag(:th, text, options)
    end

    last_sort_order = last_sort_ordering(model_name, field)
    case last_sort_order
    when nil    then caret = ''
    when 'desc' then caret = content_tag(:i, '', class: "fa fa-angle-down")
    when 'asc'  then caret = content_tag(:i, '', class: "fa fa-angle-up")
    end

    data = {
      field: field,
      ordering: next_sort_ordering(last_sort_order),
    }
    data.merge!('last-ordering' => last_sort_order) unless last_sort_order.blank?

    content_tag(:th, options) do
      link_to(
        "#sort_#{field}",
        data: data,
        class: "sortable-table-header #{'table-header-sorting' unless caret.blank?}"
      ) do
        if caret.blank?
          text
        else
          (text + " " + content_tag(:strong, caret).html_safe).html_safe
        end
      end
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
    if args.first.is_a?(Search::Query)
      query = args.first
    else
      query = @query
    end
    options = args.last.is_a?(Hash) ?  args.last : {}

    builder = SearchFormBuilder.new(
      model, query, self, @current_user, last_search
    )

    output = capture(builder, &block)
    action = if query
      options[:method] ||= 'PUT'
      search_query_path(query)
    else
      options[:method] ||= 'GET'
      search_path
    end
    options[:id] ||= "#{model.name.underscore}_search"
    add_class options, 'search-form'

    options[:data] ||= {}
    options[:data][:model] = model.name.underscore

    form_tag(action, options) { output }
  end

  # Gets a select box for the current user's saved queries on the given
  # model class.
  def select_search_queries(model, options={})
    return unless @current_user
    add_class options, 'form-control', 'search-query-select'
    options[:id] = "select_query_for_#{model.name.underscore}"
    select_options = content_tag(:option, "Saved Searches", value: 'nil')

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

  def batch_fields_for(object, options = {}, &block)
    builder = BatchFormBuilder.new(
        object.class.name.underscore, object, self, options
      )
    return builder unless block_given?

    capture(builder, &block)
  end

  def inline_field_tag(object, method, default_or_options = {}, options = {})
    if default_or_options.is_a? Hash
      options = default_or_options
      default = method.to_s.gsub(/_/, ' ')
    else
      default = default_or_options
    end

    add_class options, 'inline-field'
    # TODO change resource- to data-resource for validity
    options.merge! ({
          :contenteditable          => true,
          'resource-name'           => object.class.name.underscore,
          'resource-plural'         => object.class.name.underscore.pluralize,
          'resource-id'             => object.id,
          'resource-method'         => method,
          'data-authenticity_token' => form_authenticity_token
        })

    content = object.send(method) || default
    content_tag(:span, content, options)
  end

  def size_price_field(f, field, price)
    f.text_field field,
      class: "form-control upcharge-#{field}",
      value: (number_with_precision(price, precision: 2) || 0),
      disabled: f.object.try("#{field}_nil")
  end
end
