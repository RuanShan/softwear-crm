module Search
  class FilterGroup < ActiveRecord::Base
    include FilterType
    has_many :filters, as: :filter_holder, dependent: :destroy

    # 's' is the secret DSL object that captures our block contexts.
    # We call all_of or any_of on it, depending on how this group is
    # configured.
    def apply(s, base)
      s.send(of_func) do
        filters.each do |filter|
          filter.apply(self, base)
        end
      end
    end

    def of_func
      all? ? :all_of : :any_of
    end

    # Find the filter for the given field recursively within this group.
    def find_field(field)
      filters.each do |f|
        case f.type
        when FilterGroup
          result = f.type.find_field(field)
          return result if result
        
        else
          return f if f.field.to_sym == field.name.to_sym
        end
      end

      nil
    end
  end
end