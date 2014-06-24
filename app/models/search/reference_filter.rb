module Search
  class ReferenceFilter < ActiveRecord::Base
    include FilterType
    belongs_to :value, polymorphic: true
  end
end