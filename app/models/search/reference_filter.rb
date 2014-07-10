module Search
  class ReferenceFilter < ActiveRecord::Base
    include FilterType
    belongs_to :value, polymorphic: true
    belongs_to_search_type :reference

    def self.assure_value(value)
      if value.is_a? String
        split = value.split '#'
        model = Kernel.const_get split.first
        id = split.last

        model.find(id)
      else
        super
      end
    end
  end
end
