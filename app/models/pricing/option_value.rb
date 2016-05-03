module Pricing
  class OptionValue < ActiveRecord::Base
    self.table_name = "pricing_option_values"

    belongs_to :option_type

    def display
      "#{option_type.name}: #{value}"
    end
  end
end