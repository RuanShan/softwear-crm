class LancengFormBuilder < ActionView::Helpers::FormBuilder
  def self.dummy_for(object)
    temp = Class.new do
      include ActionView::Helpers::FormHelper
      include ActionView::Helpers::FormOptionsHelper
      attr_accessor :output_buffer
    end.new
    return self.new object.class.name.underscore.to_sym, object, temp, {}, nil
  end

  def text_field(method, options={})
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

  def check_box_with_text_field(check_method, text_method, options={})
    @template.content_tag(:div, class: 'input-group') do
      add_class options, 'form-control'
      @template.content_tag(:span, class: 'input-group-addon') do
        @template.check_box @object_name, check_method
      end +
      @template.text_area(@object_name, text_method, options)
    end
  end

  def error_for(method)
    @object.errors.full_messages_for(method).each do |message|
      @template.content_tag(:p, message, class: 'text-danger', for: "#{@object_name}[#{method}]")
    end if @object.errors.include? method
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
end