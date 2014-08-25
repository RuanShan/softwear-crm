module Search
  module NumberFilterType
    extend ActiveSupport::Concern

    included do
      include FilterType

      # The comparator is how the field's value is compared to the filter's.
      validates_inclusion_of :comparator,
                             in: ['>', '<', '='],
                             message: "must be '>', '<', or '='"
      
      after_initialize -> { self.comparator ||= '=' }

      def apply(s, base=nil)
        if comparator == '='
          s.send(with_func, field, value)
          # with :price, 50.00
        else
          s.send(with_func, field).send(comparator_func, value)
          # with(:price).greater_than(50.00)
        end
      end
    end

    def comparator_func
      if comparator == '>'
        :greater_than
      elsif comparator == '<'
        :less_than
      else
        raise "#{self.class.name}
                comparator must be > or < to use comparator_func"
      end
    end
  end
end