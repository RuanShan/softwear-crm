module Search
  # Represents a filter on another object, such as an Order's salesperson.
  class ReferenceFilter < ActiveRecord::Base
    include FilterType

    belongs_to :value, polymorphic: true
    belongs_to_search_type :reference

    # Decodes string values from search forms. See filter_type.rb.
    # This string encoding happens inside helpers/search_form_builder.rb.
    def self.assure_value(value)
      if value.is_a? String
        split = value.split '#'
        model = Kernel.const_get split.first
        id = split.last

        model.find(id)
      else
        value
      end
    end
  end
end
