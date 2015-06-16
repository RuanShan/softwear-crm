ActionView::Helpers::FormBuilder.class_eval do
  def select2(method, choices = nil, options = {}, html_options = {}, &block)
    if html_options.key?('class')
      original_class = html_options['class']
      unless original_class.include?('select2')
        html_options = html_options.merge(class: "#{original_class} select2")
      end
    else
      html_options = html_options.merge(class: 'select2')
    end
    select(method, choices, options, html_options, &block) + @template.javascript_tag("$('.select2').select2();")
  end
end
