class OrderFormBuilder < ActionView::Helpers::FormBuilder
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
      @template.content_tag(:span, class: 'input-group-addon') do
        @template.check_box @object_name, check_method
      end +
      @template.text_area(@object_name, text_method, options)
    end
  end

  def datetime(method, options={})
    options[:type] = 'datetime'
    options[:name] = "#{@object_name}[#{method.to_s}]"
    options[:id] ||= "#{@object_name}_#{method.to_s}"
    add_class options, 'form-control', 'datepicker-input'
    
    @template.content_tag(:input, options) {}
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