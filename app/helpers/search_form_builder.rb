# This currently does not support filter groups, although QueriesController is ready to handle them for the occasion.
class SearchFormBuilder
  include FormHelper

  class YesOrNo
    def initialize(display, value)
      @display = display
      @value = value
    end
    def name
      @display
    end
    def to_s
      @value
    end
  end
  # TODO see if this works instead of the dumb class up there:
  # YesOrNo = Struct.new(:name, :to_s)

  # Just pass <metadata option>: true to the options of any field method, and it will be applied
  # (boolean is automatically applied for yes/no radios and checkbox)
  METADATA_OPTIONS = [:negate, :greater_than, :less_than]

  YES_OR_NO_CHOICES = [YesOrNo.new('Yes', 'true'), YesOrNo.new('No', 'false')]

  def initialize(model, query, template, current_user=nil, last_search=nil, locals={})
    @model = model
    @query = query
    @template = template
    @last_search = last_search
    @current_user = current_user
    @locals = locals

    @filter_group_stack = [:all] # Not currently actually using this.
    @field_count = 0
  end

  # Remember to define self.permitted_search_locals in your controller
  def pass_locals_to_controller(locals)
    raise SearchException, "Locals should be a hash" unless locals.is_a? Hash
    content = "".html_safe
    locals.each do |k,v|
      content.send(
        :original_concat,
        @template.hidden_field_tag("locals[#{k}]", v.to_s)
      )
    end
    content
  end

  # These methods are not actually useful right now.
  [:filter_all, :filter_any].each do |method_name|
    define_method(method_name) do |&block|
      raise SearchException, "Filter groups in search forms aren't quite implemented yet."
      @filter_group_stack.push method_name.to_s.last(3).to_sym
      block.call(self)
      @filter_group_stack.pop
    end
  end

  def label(field_name, content_or_options={}, options={}, &block)
    content = ""
    if content_or_options.is_a?(Hash)
      options = content_or_options
      content = field_name.to_s.humanize
    else
      content = content_or_options.to_s
    end
    @template.label_tag(
      input_name_for(field_name, @field_count + 1), content, options, &block
    )
  end

  def fulltext(options={})
    preprocess_options options, 'fulltext'

    initial_value = if query_model
                      query_model.default_fulltext
                    elsif @last_search
                      if @last_search.is_a? Hash
                        (@last_search[model_name] && @last_search[model_name][:fulltext]) ||
                            @last_search[:fulltext]
                      else
                        begin
                          query = Search::Query.find(@last_search.to_i)
                          query_model = query.query_models.where(name: @model.name).first
                          if query_model.nil?
                            ''
                          else
                            query_model.default_fulltext
                          end
                        rescue ActiveRecord::RecordNotFound
                          ''
                        end
                      end
                    end

    is_textarea = options.delete :textarea
    func = is_textarea ? :text_area_tag : :text_field_tag

    name = if @model
             "search[#{model_name}[fulltext]]"
           else
             "search[fulltext]"
           end

    @template.send func, name, initial_value, options
  end

  def select(field_name, choices, options={})
    raise SearchException, "Cannot call select unless a model is specified" if @model.nil?
    preprocess_options options, field_name

    initial_value = initial_value_for field_name
    display_method = options.delete(:display) || :name

    select_options = @template.content_tag(:option, options.delete(:nil) || "#{field_name.to_s.humanize}...", value: 'nil')

    # TODO rather than doing this imperatively, you can use 
    # reduce(<insert initial value of select_options here>) 
    # with a block similar to that.
    choices.each do |item|
      name = if item.respond_to? display_method
               item.send(display_method)
             else item.to_s end

      value = if item.respond_to? :id
                "#{item.class.name}##{item.id}"
              else item.to_s end

      select_options.send :original_concat, @template.content_tag(:option,
                                                                  name, value: value,
                                                                  selected: value.to_s == initial_value.to_s ? 'selected' : nil) unless value.empty?
    end

    @field_count += 1
    process_options(field_name, options) +
        @template.select_tag(input_name_for(field_name), select_options, options)
  end

  def yes_or_no_select(field_name, options={})
    select(field_name, YES_OR_NO_CHOICES, options)
  end

  [:text_field, :text_area, :number_field].each do |method_name|
    define_method method_name do |field_name, options={}|
      raise SearchException, "Cannot call #{model_name} unless a model is specified" if @model.nil?
      preprocess_options options, field_name
      add_class(options, 'number_field') if method_name == :number_field

      @field_count += 1
      process_options(field_name, options) +
          @template.send("#{method_name}_tag", input_name_for(field_name), initial_value_for(field_name), options)
    end
  end

  def yes_or_no(field_name, options={})
    preprocess_options options, field_name
    options[:boolean] = true

    yes    = options.delete(:yes)    || 'Yes'
    no     = options.delete(:no)     || 'No'
    either = options.delete(:either) || 'Either'

    initial = initial_value_for field_name

    @field_count += 1
    process_options(field_name, options) +
        @template.content_tag(:div, class: 'form-group') do
          process_options(field_name, options) +
              @template.radio_button_tag(input_name_for(field_name), 'true', initial == 'true', options) +
              @template.content_tag(:span, yes) +
              @template.radio_button_tag(input_name_for(field_name), 'false', initial == 'false', options) +
              @template.content_tag(:span, no) +
              @template.radio_button_tag(input_name_for(field_name), 'nil', !initial, options) +
              @template.content_tag(:span, either)
        end
  end

  def check_box(field_name, options={})
    preprocess_options options, field_name
    add_class options, 'search-check-box'
    options[:boolean] = true

    initial_value = initial_value_for field_name

    @field_count += 1
    @template.content_tag(:div) do
      process_options(field_name, options) +
          @template.hidden_field_tag(input_name_for(field_name), 'false') +
          @template.check_box_tag(input_name_for(field_name), 'true', initial_value == 'true', options)
    end
  end

  def submit(options={})
    add_class options, 'submit', 'btn', 'btn-primary'
    @template.submit_tag(options[:value] || (@query ? 'Save' : 'Search'), options)
  end
  alias_method :search, :submit

  # This outputs a button that will save the query instead of searching it
  def save(options={})
    add_class options, 'submit', 'btn', 'btn-primary', 'btn-search-save'

    @template.hidden_field_tag('query[name]', '', disabled: true, class: 'query_name') +
        @template.hidden_field_tag('query[user_id]', @current_user ? @current_user.id : -1, disabled: true, class: 'user_id') +
        @template.hidden_field_tag('target_path', '', disabled: true, class: 'target_path') +
        @template.button_tag(options[:value] || 'Save', options.merge(type: 'button'))
  end

  private
  def preprocess_options(options, field_name)
    add_class options, 'form-control'
    # options[:id] ||= id_for field_name
  end

  def traverse(h,&b)
    h.each do |k,v|
      case v
        when Hash
          traverse(v,&b)
        else
          b.call k, v
      end
    end
  end

  def initial_value_for(field_name)
    if @query.nil?
      if @last_search
        # If it's a number, it was a query
        if (@last_search.is_a?(String) && @last_search =~ /\d+/) || @last_search.is_a?(Fixnum)
          begin
            last_query = Search::Query.find(@last_search.to_i)
            existing_filter = last_query.filter_for @model, field_name
            return existing_filter.value unless existing_filter.nil?
          rescue ActiveRecord::RecordNotFound
          end
          # Otherwise it must be a hash of search params
        elsif @last_search[model_name]
          traverse @last_search[model_name] do |k,v|
            if k.to_s == field_name.to_s
              return v == 'nil' ? nil : v
            end
          end
        end
      end
    else
      existing_filter = @query.filter_for @model, field_name
      return existing_filter.value unless existing_filter.nil?
    end
    nil
  end

  def current_depth
    @filter_group_stack.count
  end

  def query_model
    if @query.nil?
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

  # TODO When groups are implemented, these will have to be different
  def input_name_for(field_name, num=nil)
    "search[#{model_name}[#{num || @field_count}[#{field_name}]]]"
  end

  def metadata_name_for(field_name)
    "search[#{model_name}[#{@field_count}[_metadata]]][]"
  end
end