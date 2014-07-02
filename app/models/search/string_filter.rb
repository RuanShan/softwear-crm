module Search
  class StringFilter < ActiveRecord::Base
    include FilterType
    belongs_to_search_type :string
  end
end