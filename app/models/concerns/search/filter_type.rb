module Search
  module FilterType
    extend ActiveSupport::Concern

    included do
      has_one :filter, as: :filter_type
      FilterTypes << self
    end

    def method_missing(name, *args, &block)
      filter.send name, *args, &block
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