ActiveRecord::Base.class_eval do
  class << self
    alias_method :super_searchable, :searchable
    def searchable(*args, &block)
      Search::Models.register self
      Sunspot::DSL::Fields.instance_variable_set '@current_model', self
      super_searchable(*args, &block)
    end

    def searchable_fields
      @searchable_fields ||= {}
    end
  end
end

Sunspot::DSL::Fields.class_eval do
  alias_method :super_text, :text
  def text(*args, &block)
    super_text(*args, &block)
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
      current_model.searchable_fields[field.to_sym] = Search::Field.new(
        current_model, field.to_sym, search_type.to_sym)
    end
  end
  def current_model
    Sunspot::DSL::Fields.instance_variable_get '@current_model'
  end
end

Sunspot::Rails::Adapters::ActiveRecordDataAccessor.class_eval do
  # The default implementation of this just grabs @clazz.all - which might include
  # an ordering which would override the search's ordering... So we go off of
  # unscoped and test for deleted_at if applicable, since that's the only important
  # thing that tends to be in the default scope.
  def load_all(ids)
    r = @clazz.unscoped
    r = r.where(deleted_at: nil) if @clazz.column_names.include?(:deleted_at)
    r = r.includes(@include)     if @include
    r = r.select(@select)        if @select
    Rails.logger.debug "LOADING ALL FOR SUNSPOT!"
    r.where(@clazz.primary_key => ids)
  end
end

require_relative 'sunspot_custom_types'
require Rails.root + 'lib/util/generic_decorators.rb'
# Eager load all the models so that the search data is readily available
require Rails.root + 'app/models/search.rb'
Dir[Rails.root + 'app/models/**/*.rb'].each do |file|
  next if file.include?('/concerns/') || file.include?('/freshdesk_local/')

  if file.include? '/liquid/'
    require file
  else
    /app\/models\/(?<model_name>[\w\/]+\.rb)/ =~ file
    Kernel.const_get "#{model_name.gsub('.rb', '').camelize}"
  end
end
