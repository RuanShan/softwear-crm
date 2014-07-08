module Search
  class FilterGroup < ActiveRecord::Base
    include FilterType
    has_many :filters, as: :filter_holder, dependent: :destroy

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
  end
end