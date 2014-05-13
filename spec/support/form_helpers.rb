require 'rspec/expectations'

module FormHelpers
	def within_form_for(model_name)
		@@model_form_context = model_name.to_s.downcase
		yield
		@@model_form_context = nil
	end

	RSpec::Matchers.define :have_field_for do |field_name|
		match do |page|
			if @@model_form_context
				doc = Nokogiri::HTML page
				css_attr = "[name='#{@@model_form_context}[#{field_name}]']"
	      !(doc.css("input#{css_attr}").empty? and
					doc.css("select#{css_attr}").empty? and
					doc.css("textarea#{css_attr}").empty?)
			end
		end
		failure_message_for_should do |page|
			"Couldn't find field for #{@@model_form_context}.#{field_name} in page: #{page}"
		end
	end
end