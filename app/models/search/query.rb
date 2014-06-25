module Search
  class Query < ActiveRecord::Base
    belongs_to :user
    has_many :query_models, class_name: 'Search::QueryModel', dependent: :destroy
    validates :name, uniqueness: { scope: :user_id }

    class SearchList < Array
      def initialize(models, &block)
        super(models.map.with_index(&block))
      end

      def combine
        map do |search|
          search.results.map.with_index do |result, i|
            { search.hits[i].score => result }
          end
        end.flatten.sort do |a,b|
          a.keys.first <=> b.keys.first 
        end.map { |e| e.values.first }
      end
    end

    def models
      if query_models.empty?
        Models.all
      else
        query_models.map(&:model)
      end
    end

    def search(*args, &block)
      options = if args.last.is_a? Hash
        args.last
      else {} end

      text = if args.first.is_a? String
        args.first
      else default_fulltext end

      SearchList.new(models) do |model, i|
        text_fields = text_fields_at(i)
        query_model = query_models[i]

        model.search do
          if text && !text.empty?
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
          block.call if block_given?
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