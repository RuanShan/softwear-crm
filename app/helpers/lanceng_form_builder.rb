class LancengFormBuilder < ActionView::Helpers::FormBuilder
  include FormHelper
  def self.dummy_for(object)
    temp = Class.new do
      include ActionView::Helpers::FormHelper
      include ActionView::Helpers::FormOptionsHelper
      attr_accessor :output_buffer
    end.new
    return self.new object.class.name.underscore.to_sym, object, temp, {}, nil
  end

  def common_attr(attrs)
    @common_attrs ||= {}
    @common_attrs.merge! attrs
  end

  # Adding form-control class to standard field functions
  def select(method, choices, o = {}, options = {})
    add_class options, 'form-control'
    super method, choices, o, options
  end
  # Super efficient mass method reassignment, go!
  %i(text_field password_field text_area
     number_field check_box).each do |method_name|
    alias_method "original_#{method_name}".to_sym, method_name
    define_method method_name do |*args|
      # TODO: refactor
      options =
        args.size == 2 ? args.last.merge({}) : {}

      add_class options, 'form-control'
      add_class(options, 'number_field') if method_name == :number_field

      send("original_#{method_name}".to_sym, args.first, options)
    end
  end

  # Quick method for adding a label to a field. Can be called like
  # f.label.text_area :name
  # OR
  # f.label("Display Text").text_field :name
  # 
  # or just used normally
  def label(*args)
    if args.empty? || args.first.is_a?(String)
      l = args.first.is_a?(String) ? args.first : nil
      proxy :label, l
    else
      super
    end
  end

  # Another quick method, this time for errors. Stacks with label.
  # Potential use:
  # f.label.error.text_area :name
  def error(*args)
    # TODO: look at parenthesis being used here
    args.empty? ? proxy(:error_for) : error_for(*args)
  end

  def inline_field(method, default_or_options = {}, options = {})
    @template.inline_field_tag(@object, method, default_or_options, options)
  end

  # TODO: write self commenting code?
  # Gives you a checkbox with a textfield attached to it.
  # Useful for a condition and a reason
  # TODO: refactor to not use +
  def check_box_with_text_field(check_method, text_method, options = {})
    @template.content_tag(:div, class: 'input-group') do
      add_class options, 'form-control'
      @template.content_tag(:span, class: 'input-group-addon') do
        @template.check_box @object_name, check_method
      end +
      @template.text_area(@object_name, text_method, options)
    end
  end

  def has_errors_on?(method)
    @object.errors.include? method
  end

  def error_for(method)
    if @object.errors.include? method
      # TODO: refactor
      c =
        @object.errors.full_messages_for(method).collect do |message|
          @template.content_tag(:p, message, class: 'text-danger', for: "#{@object_name}[#{method}]")
        end.join

      @template.content_tag(:div, c, { class: 'error' }, false)
    end
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

  private

  # TODO: refactor
  def proxy(method_name, *extras)
    @proxy_stack ||= []
    @proxy_stack << { func: method_name, args: extras }
    Class.new do
      def initialize(f); @f = f; end
      def is_proxy?; true; end
      def method_missing(name, *args, &block)
        result = @f.send(name, *args, &block)
        if result.respond_to? :is_proxy?
          result
        else
          r = ActiveSupport::SafeBuffer.new
          @f.instance_variable_get('@proxy_stack')[0..-1].each do |e|
             r.send :original_concat, @f.send(e[:func], *([args.first] + e[:args]).compact) || ''
          end
          @f.instance_variable_get('@proxy_stack').clear()
          r.send :original_concat, result || ''
        end
      end
    end.new(self)
  end
end
