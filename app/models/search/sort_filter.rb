module Search
  class SortFilter < ActiveRecord::Base
    include FilterType

    def apply(s, base)
      f = field
      v = value # asc or desc

      base.instance_eval do
        order_by f, v
      end
    end
  end
end
