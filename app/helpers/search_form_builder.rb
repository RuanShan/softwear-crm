# This currently does not support filter groups, although QueriesController
# is ready to handle them for the occasion.
class SearchFormBuilder
  include FormHelper

  YesOrNo = Struct.new(:name, :value) { alias_method :to_s, :value }

  # Just pass <metadata option>: true to the options of any field method,
  # and it will be applied
  # (boolean is automatically applied for yes/no radios and checkbox)
  METADATA_OPTIONS = [:negate, :greater_than, :less_than]

  YES_OR_NO_CHOICES = [YesOrNo.new('Yes', 'true'), YesOrNo.new('No', 'false')]

  def initialize(model, query, template, current_user=nil,
                 last_search=nil, locals={})
    @model        = model
    @query        = query if query
    @template     = template
    @last_search  = last_search
    @current_user = current_user
    @locals       = locals
    @field_count  = 0
    @field_initial_values = Hash.new(0)
  end

  # Remember to define self.permitted_search_locals in your controller
  def pass_locals_to_controller(locals)
    raise SearchException, "Locals should be a hash" unless locals.is_a? Hash

    locals.reduce(''.html_safe) do |content, l|
      name  = l.first
      value = l.last

      content.send(
        :original_concat,
        @template.hidden_field_tag("locals[#{name}]", value.to_s)
      )
    end
  end

  def any_of
    @any = true
    yield
    @any = false
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

    is_textarea = options.delete :textarea
    func = is_textarea ? :text_area_tag : :text_field_tag
    name = @model      ? "search[#{model_name}][fulltext]" : "search[fulltext]"

    @template.send func, name, initial_fulltext_value, options
  end

  def select(field_name, choices, options={})
    if @model.nil?
      raise SearchException, "Cannot call select unless a model is specified"
    end
    preprocess_options options, field_name

    if options[:multiple]
      select_options = ''.html_safe
      options[:data] ||= {}
      options[:data][:placeholder] = "#{field_name.to_s.humanize}..."
    else
      initial_option = options.delete(:nil) || "#{field_name.to_s.humanize}..."

      select_options =
        @template.content_tag(:option, initial_option, value: 'nil')
    end

    choices.reduce(select_options, &compile_select_options(field_name, options))

    add_class(options, 'select2')

    @field_count += 1
    process_options(field_name, options) +
      @template.select_tag(input_name_for(field_name), select_options, options)
  end

  def yes_or_no_select(field_name, options={})
    select(field_name, YES_OR_NO_CHOICES, options)
  end

  %i(text_field text_area number_field).each do |method_name|

    define_method method_name do |field_name, options={}|
      if @model.nil?
        raise SearchException,
              "Cannot call #{model_name} unless a model is specified"
      end
      preprocess_options options, field_name
      add_class(options, 'number_field') if method_name == :number_field

      @field_count += 1
      tag = @template.send("#{method_name}_tag",
          input_name_for(field_name), initial_value_for(field_name), options
        )

      process_options(field_name, options) + tag
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

    c     = @template.method(:content_tag)
    radio = @template.method(:radio_button_tag)
    input_name = input_name_for(field_name)

    @template.content_tag(:div, class: 'form-group') do
      process_options(field_name, options) +
      radio[input_name, 'true',  initial == 'true',  options] + c[:span, yes] +
      radio[input_name, 'false', initial == 'false', options] + c[:span, no]  +
      radio[input_name, 'nil',   !initial,           options] + c[:span, either]
    end
  end

  def check_box(field_name, options={})
    preprocess_options options, field_name
    add_class options, 'search-check-box'
    options[:boolean] = true

    initial_value = initial_value_for field_name
    input_name    = input_name_for field_name

    @field_count += 1
    @template.content_tag(:div) do
      process_options(field_name, options) +

      @template.hidden_field_tag(input_name, 'false') +

      @template.check_box_tag(
        input_name, 'true', initial_value == 'true', options
      )
    end
  end

  def submit(options={})
    add_class options, 'submit', 'btn', 'btn-primary'
    value = options[:value] || (@query ? 'Save' : 'Search')

    @template.submit_tag(value, options)
  end

  alias_method :search, :submit

  # This outputs a button that will save the query instead of searching it
  def save(options={})
    add_class options, 'submit', 'btn', 'btn-primary', 'btn-search-save'

    user_id = @current_user ? @current_user.id : -1

    html = lambda do |clazz|
      { disabled: true, class: clazz }
    end
    hidden = @template.method(:hidden_field_tag)
    value = options[:value] || 'Save'

    hidden.('query[name]', '', html['query_name']) +
    hidden.('query[user_id]', user_id, html['user_id']) +
    hidden.('target_path', '', html['target_path']) +
    @template.button_tag(value, options.merge(type: 'button'))
  end

  private

  def preprocess_options(options, field_name)
    add_class options, 'form-control'
  end

  def traverse(h,&b)
    return if h.nil?
    h.each do |k,v|
      case v
        when Hash
          traverse(v,&b)
        else
          b.call k, v
      end
    end
  end

  def compile_select_options(field_name, options)
    initial_value  = (initial_value_for field_name) || options[:selected]
    display_method = options.delete(:display) || :name

    proc do |total, item|
      if item.is_a?(Array)
        name  = item[0]
        value = item[1]
      else
        name  = item.try(display_method) || item.to_s
        value = "#{item.class.name}##{item.id}" rescue item.to_s
      end

      next total if value.empty?

      if initial_value.is_a?(Array)
        selected = initial_value.include?(value.to_s) ? 'selected' : nil
      else
        selected = value.to_s == initial_value.to_s ? 'selected' : nil
      end
      option =
        @template.content_tag(:option, name, value: value, selected: selected)

      total.send(:original_concat, option)
    end
  end

  def initial_fulltext_value
    return query_model.default_fulltext if query_model
    return nil unless @last_search

    case @last_search
    when Hash then (@last_search[model_name] || @last_search)[:fulltext]
    else
      begin
        query       = Search::Query.find(@last_search.to_i)
        query_model = query.query_models.where(name: @model.name).first

        return '' if query_model.nil?

        query_model.default_fulltext

      rescue ActiveRecord::RecordNotFound
        ''
      end
    end
  end

  def query_initial_value(field_name, last_query = nil)
    if last_query.nil?
      return nil unless @last_search.is_a?(String) || @last_search.is_a?(Fixnum)
      return nil if @last_search.is_a?(String) && !(@last_search =~ /\d+/)
      begin
        last_query = Search::Query.find(@last_search)
      rescue ActiveRecord::RecordNotFound
        return nil
      end
    end

    @already_found ||= {}

    existing_filter = last_query.filter_for(@model, field_name) { |f| !@already_found[f.id] }

    return nil if existing_filter.nil?

    @already_found[existing_filter.id] = true
    return @template.assure_search_value(existing_filter)
  end

  def hash_initial_value(field_name)
    return nil unless @last_search.is_a?(Hash)

    find_count = 0
    traverse @last_search[model_name] do |k,v|
      # @field_initial_values
      if k.to_s == field_name.to_s
        if @field_initial_values[k.to_s] > find_count
          find_count += 1
          next
        end

        @field_initial_values[k.to_s] += 1
        return v == 'nil' ? nil : v
      end
    end
  end

  def initial_value_for(field_name)
    value = query_initial_value(field_name, @query) || hash_initial_value(field_name)
    if value.respond_to?(:strftime)
      @template.value_time(value)
    else
      value
    end
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
    METADATA_OPTIONS.reduce(''.html_safe) do |buf, meta|
      next buf unless options.delete(meta)
      buf + @template.hidden_field_tag(metadata_name_for(field_name), meta.to_s)
    end
  end

  def input_name_for(field_name, num=nil)
    num ||= @field_count

    if @any
      "search[#{model_name}][#{num}][_group][#{num}][#{field_name}]"
    else
      "search[#{model_name}][#{num}][#{field_name}]"
    end
  end

  def metadata_name_for(field_name)
    if @any
      "search[#{model_name}][#{@field_count}][_group][#{@field_count}][_metadata][]"
    else
      "search[#{model_name}][#{@field_count}][_metadata][]"
    end
  end
end
