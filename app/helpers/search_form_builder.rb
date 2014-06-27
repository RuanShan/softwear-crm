class SearchFormBuilder
  include FormHelper

  def initialize(model, query, template)
    @model = model
    @model_name = model.name.underscore
    @query = query || Search::Query.new
    @template = template

    @filter_group_stack = [:all]
    @field_count = 0
  end

  [:filter_all, :filter_any].each do |method_name|
    define_method(method_name) do |&block|
      @filter_group_stack.push method_name.to_s.last(3).to_sym
      block.call(self)
      @filter_group_stack.pop
    end
  end

  def text_field(field_name, *args)
    options = get_options args
    add_class(options, 'form-control')
    existing_filter = @query.filter_for @model, field_name

    @field_count += 1
    @template.text_field_tag input_name_for(field_name), initial_value_for(field_name)
  end

private
  def get_options(args)
    if args.last && args.last.is_a?(Hash)
      args.last
    else
      {}
    end
  end

  def initial_value_for(field_name)
    existing_filter = @query.filter_for @model, field_name
    if existing_filter
      existing_filter.value
    else
      ''
    end
  end

  def current_depth
    @filter_group_stack.count
  end

  def input_name_for(field_name)
    # Unsure yet if this works out alright
    "search[#{@model_name}[#{@field_count}[#{field_name}]]]"
  end
end