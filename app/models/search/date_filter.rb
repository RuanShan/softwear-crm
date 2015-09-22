module Search
  class DateFilter < ActiveRecord::Base
    include NumberFilterType
    belongs_to_search_type :date

    def value=(new_value)
      return super unless new_value.is_a?(String)

      time_zone = Time.zone.now.strftime('%Z')
      utc_time  = DateTime.strptime(
        "#{new_value} #{time_zone}", '%m/%d/%Y %l:%M %p %Z'
      )
        .to_time.utc

      super(utc_time)
    end
  end
end
