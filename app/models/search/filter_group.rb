module Search
  class FilterGroup < ActiveRecord::Base
    include FilterType
    has_many :filters, as: :filter_holder
  end
end