module FormBuilderHelpers
  class DummyOutputBuffer
    include ActionView::Helpers::FormHelper
    include ActionView::Helpers::FormOptionsHelper
    attr_accessor :output_buffer

    def initialize
      @output_buffer = ''.html_safe
    end
  end

  def test_form_for(object, options = {}, &block)
    builder_class = options[:builder] || ActionView::Base.default_form_builder

    object_name = case object
      when Symbol, String then object
      else object.class.name.underscore.to_sym
      end

    buffer  = DummyOutputBuffer.new
    args = if block_given?
        yield object_name, object, buffer
      else
        [object_name, object, buffer, {}]
      end

    builder = builder_class.new(*args)
  end
end
