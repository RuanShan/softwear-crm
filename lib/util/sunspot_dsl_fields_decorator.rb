ActiveRecord::Base.class_eval do
  class << self
    alias_method :super_searchable, :searchable
    def searchable(*args, &block)
      Sunspot::DSL::Fields.instance_variable_set '@model_name', self.name
      super_searchable(*args, &block)
    end
  end
end

Sunspot::DSL::Fields.class_eval do
  alias_method :super_text, :text
  def text(*args)
    super_text(*args)
    # TODO call Search::Field.ensure_for
  end

  alias_method :super_method_missing, :method_missing
  def method_missing(name, *args, &block)
    super_method_missing(name, *args, &block)

  end

private
  def model_name
    Sunspot::DSL::Fields.instance_variable_get '@model_name'
  end
end