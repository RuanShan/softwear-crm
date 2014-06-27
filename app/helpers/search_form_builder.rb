class SearchFormBuilder
  include FormHelper

  def initialize(model, query, template)
    @model = model
    @model_name = model.name.underscore
    @query = query
    @template = template

    @filter_group_stack = [:all]
    @field_count = 0
  end

  [:filter_all, :filter_any].each do |method_name|
    define_method(method_name) do |&block|
      @filter_group_stack.push method_name.to_s.last(3).to_sym
      block.call(self)
      @filter_group_stack.pop
    end
  end

  def text_field(field_name)
    @template.text_field_tag input_name_for(field_name)
    # TODO query needs a #filter_value_for(model, field) method
    # so, go spec that out and make it happen!
  end

private
  def current_depth
    @filter_group_stack.count
  end

  def input_name_for(field_name)
    # Unsure yet if this works out alright
    "search[#{@model_name}#{@field_count}[#{field_name}]]]"
  end
end