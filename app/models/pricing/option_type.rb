module Pricing
  class OptionType < ActiveRecord::Base
    self.table_name = "pricing_option_types"

    belongs_to :imprint_method, class_name: "ImprintMethod"
    has_many :option_values

    accepts_nested_attributes_for :option_values, allow_destroy: true
  end
end