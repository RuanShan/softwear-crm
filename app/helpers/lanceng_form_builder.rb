class LancengFormBuilder < ActionView::Helpers::FormBuilder
  def self.dummy_for(object)
    temp = Class.new do
      include ActionView::Helpers::FormHelper
      include ActionView::Helpers::FormOptionsHelper
      attr_accessor :output_buffer
    end.new
    return self.new object.class.name.underscore.to_sym, object, temp, {}, nil
  end

  # Adding form-control class to standard field functions
  def text_field(method, options={})
    add_class options, 'form-control'
    super
  end  
  alias_method :email_field, :text_field
  def password_field(method, options={})
    add_class options, 'form-control'
    super
  end
  def text_area(method, options={})
    add_class options, 'form-control'
    super
  end
  def select(method, choices, o={}, options={})
    add_class options, 'form-control'
    super method, choices, o, options
  end

  # Quick method for adding a label to a field. Can be called like
  # f.label.text_area :name
  def label(*args)
    if args.count == 0 || args.first.is_a?(String)
      l = args.first.is_a?(String) ? args.first : nil
      proxy :label, l
    else
      super
    end
  end
  # Another quick method, this time for errors. Potential use:
  # f.label.error.text_area :name
  def error(*args)
    if args.count == 0
      proxy :error_for
    else
      error_for *args
    end
  end

  # Creates a contenteditable span that is updated through ajax
  def inline_field(method, default_or_options={}, options={})
    default = nil
    if default_or_options.is_a? Hash
      options = default_or_options
      default = method.to_s.gsub(/_/, ' ')
    else
      default = default_or_options
    end
    options.merge! ({
          :contenteditable   => true,
          :class             => 'inline-field',
          'resource-name'    => @object_name,
          'resource-plural'  => @object_name.pluralize,
          'resource-id'      => @object.id,
          'resource-method'  => method
        })
    content = @object.send(method) || default
    @template.content_tag(:span, content, options)
  end

  # Gives you a checkbox with a textfield attached to it.
  # Useful for a condition and a reason
  def check_box_with_text_field(check_method, text_method, options={})
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
      c = @object.errors.full_messages_for(method).collect do |message|
        @template.content_tag(:p, message, class: 'text-danger', for: "#{@object_name}[#{method}]")
      end.join

      @template.content_tag(:div, c, {class: 'error'}, false)
    end
  end

  def datetime(method, options={})
    options[:type] = 'datetime'
    options[:name] = "#{@object_name}[#{method.to_s}]"
    options[:id] ||= "#{@object_name}_#{method.to_s}"
    add_class options, 'form-control', 'datepicker-input'
    
    @template.content_tag(:input, options) {}
  end

  def submit(value=nil, options={})
    add_class options, 'submit', 'btn', 'btn-primary'
    super
  end

private
  def add_class(options, *values)
    options[:class] ||= ''
    values.each do |v|
      options[:class] << ' ' unless options[:class].empty?
      options[:class] << v
    end
  end

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