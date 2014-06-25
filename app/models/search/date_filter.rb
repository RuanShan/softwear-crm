module Search
  class DateFilter < ActiveRecord::Base
    include NumberFilterType
    belongs_to_search_type :date
  end
end