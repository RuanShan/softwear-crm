module Search
  class BooleanFilter < ActiveRecord::Base
    include FilterType
    belongs_to_search_type :boolean
  end
end