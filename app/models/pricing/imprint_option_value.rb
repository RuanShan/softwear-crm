module Pricing
  class ImprintOptionValue < ActiveRecord::Base
    self.table_name = "pricing_imprint_option_values"

    belongs_to :imprint, class_name: "Imprint"
    belongs_to :option_value, class_name: "Pricing::OptionValue"
  end
end