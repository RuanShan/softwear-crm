class LancengFormBuilder < ActionView::Helpers::FormBuilder
  include FormHelper
  include NestedForm::BuilderMixin

  class MethodChain
    def initialize(builder)
      @builder = builder
    end

    def respond_to?(name)
      @builder.respond_to?(name)
    end

    def method_missing(name, *args, &block)
      result = @builder.send(name, *args, &block)
      return result if result.is_a?(MethodChain)
      
      @builder.reduce_chain(args.first) + (result || '')
    end
  end

  def common_attr(attrs)
    @common_attrs ||= {}
    @common_attrs.merge! attrs
  end

  def select(method, choices, o = {}, options = {})
    add_class options, 'form-control'
    super method, choices, o, options
  end
  
  %i(text_field password_field text_area
     number_field check_box).each do |method_name|

    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{method_name}(field, options = {}, *args)
        add_class options, 'form-control'
        #{"add_class options, 'number_field'" if method_name == :number_field}

        super(field, options, *args)
      end
    RUBY
  
  end

  # Quick method for adding a label to a field. Can be called like
  # f.label.text_area :name
  # OR
  # f.label("Display Text").text_field :name
  # 
  # or just used normally
  def label(*args)
    if args.empty? || (args.size == 1 && args.first.is_a?(String))
      display = args.first.is_a?(String) ? args.first : nil
      chain :label, display
    else
      super
    end
  end

  # Another quick method, this time for errors. Stacks with label.
  # Potential use:
  # f.label.error.text_area :name
  def error(*args)
    args.empty? ? chain(:error_for) : error_for(*args)
  end

  def inline_field(method, default_or_options = {}, options = {})
    @template.inline_field_tag(@object, method, default_or_options, options)
  end

  def check_box_with_text_field(check_method, text_method, options = {})
    @template.content_tag(:div, class: 'input-group') do
      add_class options, 'form-control'

      check_box = @template.content_tag(:span, class: 'input-group-addon') do
        @template.check_box @object_name, check_method
      end

      text_field = @template.text_area(@object_name, text_method, options)

      check_box + text_field
    end
  end

  def has_errors_on?(method)
    @object.errors.include? method
  end

  def error_for(method)
    return unless has_errors_on? method
    error_content =
      @object.errors.full_messages_for(method).map do |message|
        @template.content_tag(
          :p, message, class: 'text-danger', for: "#{@object_name}[#{method}]"
        )
      end.join

    @template.content_tag(:div, error_content, { class: 'error' }, false)
  end

  # TODO: refactor to single datetimepicker/datepicker usage
  def datetime(method, options = {})
    options[:type] = 'datetime'
    options[:name] = "#{@object_name}[#{method.to_s}]"
    options[:id] ||= "#{@object_name}_#{method.to_s}"

    add_class options, 'form-control', 'datepicker-input'
    
    @template.content_tag(:input, options) {}
  end

  def submit(value = nil, options = {})
    add_class options, 'submit', 'btn', 'btn-primary'
    super
  end

  def reduce_chain(field)
    return '' if @chain_stack.nil? || @chain_stack.empty?

    result = @chain_stack.reduce('') do |total, proc|
      total.html_safe + (proc.call(field) || '')
    end
    @chain_stack.clear

    result
  end

  def chain(method_name, *args)
    @chain_stack ||= []
    
    @chain_stack << lambda do |field|
      send(method_name, field, *args)
    end

    MethodChain.new(self)
  end  

  protected

  def with_common_attrs(options)
    options.merge(@common_attrs || {})
  end
end
