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

  def fulltext(*args)
    options = get_options args
    add_class(options, 'form-control')
    
    initial_value = @query.default_fulltext
    is_textarea = options.delete :textarea

    func = is_textarea ? :text_area : :text_field

    @template.send func, "search[fulltext]", initial_value
  end

  def select(field_name, choices, options={})
    add_class options, 'form-control'

    initial_value = initial_value_for field_name
    display_method = options[:display] || :name

    select_options = @template.content_tag(:option, "#{field_name.to_s.humanize}...", value: 'nil')
    
    choices.each do |item|
      select_options.send :original_concat, @template.content_tag(:option, 
        if item.respond_to? display_method
          item.send(display_method)
        else
          item.to_s
        end,
        value: if item.respond_to? :id
          item.id
        else
          item.to_s
        end)
    end

    @field_count += 1
    @template.select_tag input_name_for(field_name), select_options, options
  end

  [:text_field, :text_area, 
   :number_field, :check_box].each do |method_name|
     define_method method_name do |field_name, options={}|
       add_class options, 'form-control'
       options.merge!(style: 'width: 75px') if method_name == :number_field

       @field_count += 1
       @template.send("#{method_name}_tag", input_name_for(field_name), initial_value_for(field_name), options)
     end
   end

  def submit(options={})
    add_class options, 'submit', 'btn', 'btn-primary'
    @template.submit_tag(options[:value] || 'Search', options)
  end

private
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