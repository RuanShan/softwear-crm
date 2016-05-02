module Pricing
  class OptionType < ActiveRecord::Base
    self.table_name = "pricing_option_types"

    belongs_to :imprint_method, class_name: "ImprintMethod"
    has_many :option_values

    accepts_nested_attributes_for :option_values, allow_destroy: true

    after_save :assign_pending_options

    def options
      @pending_options ||= option_values.pluck(:value)
    end

    def options=(values)
      @pending_options = values
    end

    private

    def assign_pending_options
      return if @pending_options.nil? || @pending_options == option_values.pluck(:value)

      option_values.destroy_all
      # Just ignore duplicate options so that we don't run into validity problems
      set_values = {}

      @pending_options.each do |option|
        next if set_values[option]
        option_values.create(value: option)
        set_values[option] = true
      end
    end
  end
end