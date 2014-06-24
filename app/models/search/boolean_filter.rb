module Search
  class BooleanFilter < ActiveRecord::Base
    include FilterType
  end
end