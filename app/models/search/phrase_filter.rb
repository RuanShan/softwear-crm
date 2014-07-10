module Search
  class PhraseFilter < ActiveRecord::Base
    include FilterType
    belongs_to_search_type :text
    low_priority_filter_type

    def apply(s, base)
      v = value
      f = field
      base.instance_eval do
        keywords v do
          fields f
        end
      end
    end

    def self.assure_value(val)
      return val
      if val.first == '"' && val.last == '"'
        super
      else
        '"'+val+'"'
      end
    end
  end
end
