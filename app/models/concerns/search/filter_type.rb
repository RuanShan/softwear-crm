module Search
  module FilterType
    extend ActiveSupport::Concern

    included do
      has_one :filter, as: :filter_type
      FilterTypes << self
    end

    def method_missing(name, *args, &block)
      super or filter.send name, *args, &block
    end

    # Default apply function. Works for simple stuff
    # like boolean and string. Override for more 
    # complex behavior, like number.
    def apply(s)
      s.send(with_func, field, value)
    end

    def with_func
      negate? ? :without : :with
    end
  end

  # Collection of all filter types
  class FilterTypes
    class << self
      attr_reader :all

      def respond_to?(*args)
        @all.respond_to?(*args)
      end

      def method_missing(name, *args, &block)
        @all ||= []
        if @all.respond_to? name
          @all.send(name, *args, &block)
        else
          super
        end
      end
    end
  end
end