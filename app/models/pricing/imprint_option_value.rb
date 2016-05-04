module Pricing
  class ImprintOptionValue < ActiveRecord::Base
    self.table_name = "pricing_imprint_option_values"

    belongs_to :imprint, class_name: "Imprint"
    belongs_to :option_value, class_name: "Pricing::OptionValue", foreign_key: 'pricing_option_value_id'

    def option_value_id
      pricing_option_value_id
    end

    def option_value_id=(v)
      self.pricing_option_value_id = v
    end
  end
end