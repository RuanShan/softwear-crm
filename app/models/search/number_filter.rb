module Search
  class NumberFilter < ActiveRecord::Base
    include NumberFilterType
    belongs_to_search_types :double, :float, :integer
  end
end