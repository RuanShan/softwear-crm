require 'rspec/expectations'

module FormHelpers

  def within_form_for(model, options={})
    if model.is_a? ActiveRecord::Base
      @@model_id = model.id
      @@model_form_context = model.class.name.underscore
    else
      @@model_form_context = model.to_s.underscore
    end

    @@scope_to_form = options[:noscope].nil?
    yield
    @@model_form_context = nil
    @@model_id = nil
    @@scope_to_form = nil
  end

  def fill_in_inline(field, options)
    expect(options[:with]).to_not be_nil
    selector = "#{css_pre}span.inline-field[resource-method='#{field}']"
    selector += "[resource-name='#{@@model_form_context}']" if defined?(@@model_form_context) && @@model_form_context
    selector += "[resource-id='#{@@model_id}']" if defined?(@@model_id) && @@model_id
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

  RSpec::Matchers.define :have_field_for do |field_name, options={}|
    match do |page|
      doc = Nokogiri::HTML page
      css_attr = (@@model_form_context ?
                  "[name='#{@@model_form_context}[#{field_name}]']" :
                  "[name='#{field_name}']")
      inl_css_attr = ("[resource-method='#{field_name}']")

      css_attr += "[type='#{options[:type]}']" if options[:type]

      !(doc.css("#{css_pre}*#{css_attr}").empty? &&
        doc.css("#{css_pre}*#{inl_css_attr}").empty?)
    end
    failure_message do |page|
      css_attr = (@@model_form_context ? 
                  "name='#{@@model_form_context}[#{field_name}]'" :
                  "name='#{field_name}'")
      "Couldn't find field for #{css_pre}*#{css_attr} in page: #{page}"
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