module FormHelper
  def add_class(options, *values)
    options[:class] ||= ''
    values.each do |v|
      options[:class] << ' ' unless options[:class].empty?
      options[:class] << v
      options.merge!(@common_attrs) unless @common_attrs.nil?
    end
  end

  def search_form_for(model, *args, &block)
    query = args.first
    options = if args.last.is_a? Hash
      args.last
    else
      {}
    end

    builder = SearchFormBuilder.new(
      model, query, self)

    output = capture(builder, &block)
    action = if query
      search_query_path(query)
    else
      options[:method] ||= 'POST'
      search_queries_path
    end
    form_tag(action, options) { output }
  end
end