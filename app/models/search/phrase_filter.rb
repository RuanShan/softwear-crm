module Search
  # This is essencially the same as adding another fulltext to the search.
  # Generally used for when a model has multiple 'tags', and you want to
  # filter on all models that contain a certain tag.
  class PhraseFilter < ActiveRecord::Base
    include FilterType

    belongs_to_search_type :text
    # This means that if you call FilterType.of(some_field)
    # such that some_field is of search type string AND text, 
    # you will receive StringFilter instead of possibly PhraseFilter.
    low_priority_filter_type

    def apply(s, base)
      v = value
      f = field

      base.instance_eval do
        # In Sunspot, #keywords is the same as #fulltext.
        # However, when interacting with the QueryBuilder,
        # keywords actually differentiates fulltexts and phrase filters.
        # See QueryBuilder and/or QueriesController for more info.
        keywords v do
          fields f
        end
      end
    end

    # TODO Look into surrounding the phrase with quotes...
    # 
    # def self.assure_value(val)
    #   return val
    #   if val.first == '"' && val.last == '"'
    #     super
    #   else
    #     '"'+val+'"'
    #   end
    # end
  end
end
