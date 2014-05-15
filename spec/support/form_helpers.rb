require 'rspec/expectations'

module FormHelpers
  def within_form_for(model)
    if model.respond_to? :underscore
      @@model_form_context = model.underscore
    else
      @@model_form_context = model.to_s.downcase
    end
    yield
    @@model_form_context = nil
  end

  RSpec::Matchers.define :have_field_for do |field_name|
    match do |page|
      doc = Nokogiri::HTML page
      css_pre = (@@model_form_context ? 
          "form[id*='#{@@model_form_context}'] " :
          "")
      css_attr = (@@model_form_context ? 
                  "name='#{@@model_form_context}[#{field_name}]'" :
                  "name='#{field_name}'")

      if page.include? 'order[sales_status]'
        puts "#{css_pre}input[#{css_attr}]"
      else
        puts "#{css_pre}input[#{css_attr}]"
        puts css_pre
        puts css_attr
      end

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
        result = doc.css("span.field-error[for='#{@@model_form_context}[#{field_name}]']")
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