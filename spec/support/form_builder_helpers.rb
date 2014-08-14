module FormBuilderHelpers
  class DummyOutputBuffer
    include ActionView::Helpers::FormHelper
    include ActionView::Helpers::FormOptionsHelper
    attr_accessor :output_buffer

    def initialize
      @output_buffer = ''.html_safe
    end
  end

  def test_form_for(object, options = {})
    builder_class = options[:builder] || ActionView::Base.default_form_builder

    object_name = case object
      when Symbol, String then object
      else object.class.name.underscore.to_sym
      end

    buffer  = DummyOutputBuffer.new
    builder = builder_class.new(object_name, object, buffer, {}, nil)

    builder
  end
end