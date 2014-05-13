class OrderFormBuilder < ActionView::Helpers::FormBuilder
	def text_field(method, options={})
		options[:class] ||= 'form-control'
		super
	end
	def text_area(method, options={})
		options[:class] ||= 'form-control'
		super
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
		options[:class] ||= 'form-control datepicker-input'
		@template.content_tag(:input, options) {}
	end
end