module Search
  class StringFilter < ActiveRecord::Base
    include FilterType
    belongs_to_search_type :string

    def self.assure_value(value)
      if value.is_a?(String) && /^\[.*\]$/ =~ value
        JSON.parse(value)
      else
        value
      end
    end
  end
end
