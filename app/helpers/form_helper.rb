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
      options[:method] ||= 'PUT'
      search_query_path(query)
    else
      options[:method] ||= 'GET'
      search_test_path
    end
    options[:id] ||= "#{model.name.underscore}_search"
    form_tag(action, options) { output }
  end
end