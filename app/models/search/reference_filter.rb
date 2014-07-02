module Search
  class ReferenceFilter < ActiveRecord::Base
    include FilterType
    belongs_to :value, polymorphic: true
    belongs_to_search_type :reference
  end
end