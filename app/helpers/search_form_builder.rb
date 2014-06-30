# This currently does not support filter groups, although QueriesController is ready to handle them if need be.
class SearchFormBuilder
  include FormHelper

  # Just pass <metadata option>: true to the options of any field method, and it will be applied
  METADATA_OPTIONS = [:negate, :greater_than, :less_than]

  def initialize(model, query, template)
    @model = model
    @query = query || Search::Query.new
    @template = template

    @filter_group_stack = [:all] # Not currently actually using this.
    @field_count = 0
  end

  def on(model)
    # TODO do useful things here, like accept a block or whatever.
    @model = model
  end

  # These methods are not actually useful right now.
  [:filter_all, :filter_any].each do |method_name|
    define_method(method_name) do |&block|
      @filter_group_stack.push method_name.to_s.last(3).to_sym
      block.call(self)
      @filter_group_stack.pop
    end
  end

  def fulltext(field_name, options={})
    add_class options, 'form-control'
    
    initial_value = query_model.nil? ? nil : query_model.default_fulltext
    is_textarea = options.delete :textarea

    func = is_textarea ? :text_area_tag : :text_field_tag

    @template.send func, "search[fulltext]", initial_value, options
  end

  def select(field_name, choices, options={})
    raise "Cannot call select unless a model is specified" if @model.nil?
    add_class options, 'form-control'

    initial_value = initial_value_for field_name
    options[:selected] = 'selected' unless initial_value.empty?
    display_method = options.delete(:display) || :name

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
        end)
    end

    @field_count += 1
    process_options(field_name, options) +
      @template.select_tag(input_name_for(field_name), select_options, options)
  end

  [:text_field, :text_area, 
   :number_field, :check_box].each do |method_name|
     define_method method_name do |field_name, options={}|
      raise "Cannot call #{model_name} unless a model is specified" if @model.nil?
       add_class options, 'form-control'
       add_class(options, 'number_field') if method_name == :number_field

       @field_count += 1
       process_options(field_name, options) + 
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

  def query_model
    if @query.id.nil?
      nil
    else
      @query.query_models.where(name: @model.name).first
    end
  end

  def model_name
    @model.name.underscore
  end

  def process_options(field_name, options)
    buf = "".html_safe
    METADATA_OPTIONS.each do |meta|
      if options.delete meta
        buf += @template.hidden_field_tag metadata_name_for(field_name), meta.to_s
      end
    end
    buf
  end

  def input_name_for(field_name)
    "search[#{model_name}[#{@field_count}[#{field_name}]]]"
  end
  def metadata_name_for(field_name)
    "search[#{model_name}[#{@field_count}[_metadata]]][]"
  end
end