ActiveRecord::Base.class_eval do
  class << self
    alias_method :super_searchable, :searchable
    def searchable(*args, &block)
      Search::Models.register self
      Sunspot::DSL::Fields.instance_variable_set '@current_model', self
      super_searchable(*args, &block)
    end

    def searchable_fields
      @searchable_fields ||= []
    end
  end
end

Sunspot::DSL::Fields.class_eval do
  alias_method :super_text, :text
  def text(*args)
    super_text(*args)
    register_fields 'text', args
  end

  alias_method :super_method_missing, :method_missing
  def method_missing(name, *args, &block)
    super_method_missing(name, *args, &block)
    register_fields name, args
  end

  private
  def register_fields(search_type, fields)
    fields.each do |field|
      current_model.searchable_fields << Search::Field.new(
        current_model, field, search_type)
    end
  end
  def current_model
    Sunspot::DSL::Fields.instance_variable_get '@current_model'
  end
end

require_relative 'sunspot_custom_types'

Dir[Rails.root + 'app/models/**/*.rb'].each do |file|
  require file
end
