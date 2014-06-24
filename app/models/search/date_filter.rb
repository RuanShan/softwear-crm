module Search
  class DateFilter < ActiveRecord::Base
    include NumberFilterType
  end
end