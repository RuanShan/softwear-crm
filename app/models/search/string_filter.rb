module Search
  class StringFilter < ActiveRecord::Base
    include FilterType
    belongs_to_search_type :string

    def assure_value(value)
      if /^\[.*\]$/ =~ value
        JSON.parse(value)
      else
        value
      end
    end
  end
end
