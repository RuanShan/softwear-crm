module Search
  class BooleanFilter < ActiveRecord::Base
    include FilterType
    belongs_to_search_type :boolean

    def self.assure_value(value)
      if value.is_a? String
        value == 'true' ? true : false
      else
        super
      end
    end
  end
end