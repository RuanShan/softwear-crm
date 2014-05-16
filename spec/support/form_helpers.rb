require 'rspec/expectations'

module FormHelpers
  def within_form_for(model, options={})
    @@model_form_context = model.to_s.underscore
    @@scope_to_form = options[:noscope].nil?
    yield
    @@model_form_context = nil
    @@scope_to_form = nil
  end

  RSpec::Matchers.define :have_field_for do |field_name|
    match do |page|
      doc = Nokogiri::HTML page
      css_pre = (@@model_form_context && @@scope_to_form ? 
          "form[class*='#{@@model_form_context}'],form[id*='#{@@model_form_context}'] " :
          "")
      css_attr = (@@model_form_context ? 
                  "name='#{@@model_form_context}[#{field_name}]'" :
                  "name='#{field_name}'")

      !(doc.css("#{css_pre}input[#{css_attr}]").empty? and
        doc.css("#{css_pre}select[#{css_attr}]").empty? and
        doc.css("#{css_pre}textarea[#{css_attr}]").empty? and
        doc.css("#{css_pre}datetime[#{css_attr}]").empty?)
    end
    failure_message do |page|
      "Couldn't find field for #{@@model_form_context}[#{field_name}] in page: #{page}"
    end
  end

  RSpec::Matchers.define :have_error_for do |field_name|
    match do |page|
      if @@model_form_context
        doc = Nokogiri::HTML page
        result = doc.css("p.text-danger[for='#{@@model_form_context}[#{field_name}]']")
        unless result.empty? then
          define_method :error do
            result.first.text
          end
        end
        !result.empty?
      end
      failure_message do |page|
        "Found no errors for #{@@model_form_context}[#{field_name}] in page: #{page}"
      end
    end
  end
end