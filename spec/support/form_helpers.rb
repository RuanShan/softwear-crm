require 'rspec/expectations'

module FormHelpers
	def within_form_for(model)
		if model.respond_to? :underscore
			model_name = model.underscore
		else
			model_name = model.to_s.downcase
		end
		within("form.new_#{model_name}") do
			@@model_form_context = model_name
			yield
			@@model_form_context = nil
		end
	end

	RSpec::Matchers.define :have_field_for do |field_name|
		match do |page|
			doc = Nokogiri::HTML page
			css_attr = (@@model_form_context ? 
									"name='#{@@model_form_context}[#{field_name}]'" :
									"name='#{field_name}'")

      !(doc.css("input[#{css_attr}]").empty? and
				doc.css("select[#{css_attr}]").empty? and
				doc.css("textarea[#{css_attr}]").empty?)
		end
		failure_message_for_should do |page|
			"Couldn't find field for #{@@model_form_context}[#{field_name}] in page: #{page}"
		end
	end

	RSpec::Matchers.define :have_error_for do |field_name|
		match do |page|
			if @@model_form_context
				doc = Nokogiri::HTML page
				result = doc.css("span.field-error[for='#{@@model_form_context}[#{field_name}]']")
				unless result.empty? then
					define_method :error do
						result.first.text
					end
				end
				!result.empty?
			end
			failure_message_for_should do |page|
				"Found no errors for #{@@model_form_context}[#{field_name}] in page: #{page}"
			end
		end
	end
end