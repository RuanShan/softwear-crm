require 'rspec/expectations'

module FormHelpers

  def within_form_for(model, options={})
    @@model_form_context = model.to_s.underscore
    @@scope_to_form = options[:noscope].nil?
    yield
    @@model_form_context = nil
    @@scope_to_form = nil
  end

  def fill_in_inline(field, options)
    unless options[:with]
      return
    end
    selector = "#{css_pre}span.inline-field[resource-method='#{field}']"
    find(selector).set options[:with]
  end

  RSpec::Matchers.define :have_button_or_link_to do |location|
    match do |page|
      doc = Nokogiri::HTML page
      !(doc.css("#{css_pre}a[href='#{location}']").empty? && doc.css("#{css_pre}button[href='#{location}']").empty?)
    end
    failure_message do |page|
      doc = Nokogiri::HTML page
      buttons = doc.css("#{css_pre}a,#{css_pre}button")
      "Found no button leading to #{location}. Found buttons: #{buttons}"
    end
  end

  RSpec::Matchers.define :have_field_for do |field_name|
    match do |page|
      doc = Nokogiri::HTML page
      css_attr = (@@model_form_context ? 
                  "name='#{@@model_form_context}[#{field_name}]'" :
                  "name='#{field_name}'")
      inl_css_attr = ("resource-method='#{field_name}'")

      !(doc.css("#{css_pre}*[#{css_attr}]").empty? &&
        doc.css("#{css_pre}*[#{css_attr}]").empty?)
    end
    failure_message do |page|
      css_attr = (@@model_form_context ? 
                  "name='#{@@model_form_context}[#{field_name}]'" :
                  "name='#{field_name}'")
      "Couldn't find field for #{css_pre}*[#{css_attr}] in page: #{page}"
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

# private
  def css_pre
    (defined?(@@model_form_context) && @@model_form_context && @@scope_to_form ? 
      "form[class*='#{@@model_form_context}'] " :
      "")
  end
end