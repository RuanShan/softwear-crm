module Search
  module NumberFilterType
    extend ActiveSupport::Concern

    included do
      include FilterType
      validates_inclusion_of :comparator, in: ['>', '<', '='],
        message: "must be '>', '<', or '='"
      after_initialize -> { self.comparator ||= '=' }

      def apply(s)
        if comparator == '='
          s.send(with_func, field, value)
        else
          s.send(with_func, field).send(comparator_func, value)
        end
      end
    end

    def comparator_func
      if comparator == '>'
        :greater_than
      elsif comparator == '<'
        :less_than
      else
        raise "#{self.class.name} comparator must be > or < to use comparator_func"
      end
    end
  end
end