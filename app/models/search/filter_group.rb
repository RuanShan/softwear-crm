module Search
  class FilterGroup < ActiveRecord::Base
    include FilterType
    has_many :filters, as: :filter_holder, dependent: :destroy

    # 's' is the secret DSL object that captures our block contexts.
    # We call all_of or any_of on it, depending on how this group is
    # configured.
    def apply(s, base, &block)
      s.send(of_func) do
        filters.each do |filter|
          filter.apply(self, base, &block)
          block.call(filter) if block
        end
      end
    end

    def of_func
      all? ? :all_of : :any_of
    end

    # Find the filter for the given field recursively within this group.
    def find_field(field, &block)
      filters.each do |f|
        if f.type.is_a?(FilterGroup)
          result = f.type.find_field(field, &block)
          return result if result
        elsif !f.type.is_a?(SortFilter)
          return f if f.field.to_sym == field.name.to_sym && (!block_given? || yield(f))
        end
      end

      nil
    end
  end
end
