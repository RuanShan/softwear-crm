module Search
  class Query < ActiveRecord::Base
    belongs_to :user
    has_many :query_models, class_name: 'Search::QueryModel', dependent: :destroy

    def models
      if query_models.empty?
        Models.all
      else
        query_models.map(&:model)
      end
    end

    def search(*args)
      text = args.empty? ? nil : args.first

      models.map.with_index do |model, i|
        text_fields = text_fields_at(i)
        query_model = query_models[i]

        model.search do
          if text
            if text_fields && !text_fields.empty?
              fulltext(text) do
                fields(text_fields)
              end
            else
              fulltext(text)
            end
          end
          if query_model && query_model.filter
            query_model.filter.apply(self)
          end
        end
      end
    end

  private
    def text_fields_at(index)
      if query_models[index] && query_models[index].query_fields.count > 0
        query_models[index].query_fields.map do |qf|
          qf.to_h
        end.reduce({}, :merge)
      end
    end
  end
end