module Search
  module FilterType
    extend ActiveSupport::Concern

    included do
      has_one :filter, as: :filter_type, dependent: :destroy
      FilterTypes << self

      class << self
        def search_types; @search_types ||= []; end
        def belongs_to_search_type(type)
          belongs_to_search_types(*[type])
        end
        def belongs_to_search_types(*types)
          @search_types = types
        end
        def low_priority_filter_type
          @low_priority = true
        end

        def low_priority?
          @low_priority
        end

        # Some filters may have trouble with string values,
        # so this is called to get the correct value before
        # being used in a proc.
        def assure_value(value)
          value
        end

        def uses_comparator?
          column_names.include? 'comparator'
        end
      end
    end

    def method_missing(name, *args, &block)
      super or filter.send name, *args, &block
    end

    # Default apply function. Works for simple stuff
    # like boolean and string. Override for more 
    # complex behavior, like number.
    def apply(s, base=nil)
      s.send(with_func, field, value)
    end

    def with_func
      negate? ? :without : :with
    end

    def self.of(field, low_priority=false)
      raise "Field must be a Search::Field. Got #{field.class.name}." unless field.is_a? Field
      FilterTypes.each do |type|
        return type unless (field.type_names & type.search_types).empty? || 
                           (!low_priority && type.low_priority?)
      end
      return self.of(field, true) unless low_priority

      raise "#{field.model_name}##{field.name} has no filter type associated with its type(s) #{field.type_names.inspect}.
             Check the 'searchable' block in #{field.model_name.to_s.underscore}.rb or filter on a different field."
    end
  end

  # Collection of all filter types
  class FilterTypes
    class << self
      attr_reader :all

      def respond_to?(*args)
        @all.respond_to?(*args) || super
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