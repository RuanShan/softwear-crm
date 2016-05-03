class BatchFormBuilder < LancengFormBuilder
  %i(text_field password_field text_area number_field check_box hidden_field)
    .each do |method_name|

    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{method_name}(field, options = {})
        add_class options, 'form-control'
        #{"add_class options, 'number_field'" if method_name == :number_field}

        @template.#{method_name}_tag(
          field_name(field),
          @object.try(field),
          with_common_attrs(options)
        )
      end
    RUBY
  end

  def select(method, *other_args)
    raise 'Not implemented in BatchFormBuilder.
           Remove this definition if you really want to.'
  end

  def fields_for(object, *args)
    return super unless object.class.name.underscore == @object_name

    @current_id = object.id
    yield self
    @current_id = nil
  end

  private

  def field_name(field)
    "#{@object_name}[#{current_id}][#{field}]"
  end

  def current_id
    @current_id || @object.id
  end
end
