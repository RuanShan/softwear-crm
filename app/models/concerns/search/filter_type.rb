module Search
  module FilterType
    extend ActiveSupport::Concern

    included do
      has_one :filter, as: :filter_type, dependent: :destroy
      FilterTypes << self

      class << self
        def search_types; @search_types ||= []; end
        def belongs_to_search_type(type)
          belongs_to_search_types(type)
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

        # If you don't know what the comparator is, see number_filter_type.rb.
        def uses_comparator?
          column_names.include? 'comparator'
        end
      end
    end

    def method_missing(name, *args, &block)
      super || filter.send(name, *args, &block)
    end

    # Default apply function. Works for simple stuff
    # like boolean and string. Override for more 
    # complex behavior, like number or phrase.
    def apply(s, base=nil)
      if value.is_a?(String) && /\[.+\]/ =~ value
        value_to_use = JSON.parse(value)
      else
        value_to_use = value
      end
      s.send(with_func, field, value_to_use)
    end

    # Returns the name of the proper DSL function to call
    # inside a Sunspot search block.
    def with_func
      negate? ? :without : :with
    end

    # Search::FilterType.of(Field[:order, :name])
    # would evaluate to Search::StringFilter
    # 
    # assuming Order#name is defined as a string field in 
    # Order's 'searchable' block.
    def self.of(field, low_priority=false)
      unless field.is_a? Field
        raise "Field must be a Search::Field. Got #{field.class.name}."
      end

      FilterTypes.each do |type|
        return type unless (field.type_names & type.search_types).empty? || 
                           (!low_priority && type.low_priority?)
      end

      return self.of(field, true) if low_priority == false

      raise "#{field.model_name}##{field.name} has no filter type associated
             with its type(s) #{field.type_names.inspect}.
             Check the 'searchable' block in
             #{field.model_name.to_s.underscore}.rb or filter on a different
             field."
    end
  end

  # Internal collection of all filter types
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
