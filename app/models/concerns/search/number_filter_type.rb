module Search
  module NumberFilterType
    extend ActiveSupport::Concern

    included do
      include FilterType
      validates_inclusion_of :relation, in: ['>', '<', '=']

      def apply(s)
        if relation == '='
          s.send(with_func, field, value)
        else
          s.send(with_func, field).send(relation_func, value)
        end
      end
    end

    def relation_func
      if relation == '>'
        :greater_than
      elsif relation == '<'
        :less_than
      else
        raise "#{self.class.name} relation must be > or < to use relation_func"
      end
    end
  end
end