module Search
  class Query < ActiveRecord::Base
    include Softwear::Auth::BelongsToUser

    belongs_to_user
    has_many :query_models, class_name: 'Search::QueryModel',
                            dependent: :destroy
    validates :name, uniqueness: { scope: :user_id }
    validate :name_is_not_empty_if_owned_by_a_user

    # This guy is returned from #search.
    # It's clearly just an array, but the combine function lets you combine
    # the search results so that they're sorted purely by rank, rather than
    # by model then rank.
    class SearchList < Array
      def combine
        lazy
          .flat_map do |search|
            search.results.map.with_index do |result, i|
              { search.hits[i].score => result }
            end
          end
          .sort_by { |x| x.keys.first }
          .map { |x| x.values.first }
      end
    end

    def models
      query_models.empty? ? Models.all : query_models.map(&:model)
    end

    # You can pass either field_name, model_name
    # or an instance of Search::Field.
    def filter_for(*args, &block)
      field = field_from_args(args)

      return nil if field.nil?

      query_model = query_models.find do |m|
        m.name.to_sym == field.model_name.to_sym
      end

      return nil if query_model.nil?

      filter = query_model.filter

      if filter.type.is_a?(FilterGroup)
        return filter.type.find_field(field, &block)
      else
        if filter.field.to_sym == field.name.to_sym && filter.filter_type_type != 'Search::SortFilter'
          return filter if (!block_given? || yield(filter))
        end
      end
      nil
    end

    # One thing to note here:
    #
    # Most of the blocks here are passed to instance_eval, which changes `self`,
    # and therefore also the top-level methods.
    # Local variables do carry over into these blocks however.
    def search(*args, &block)
      options = args.last.is_a?(Hash) ? args.last : {}

      models = self.models.map.with_index do |model, i|
        # Locals to be used inside search DSL block.
        text_fields = text_fields_at(i)
        query_model = query_models[i]
        base_scope  = nil
        text        = fulltext_from_args(args, query_model)
        has_sort    = false

        model.search do
          # Phrase filter requires the base scope so it can add
          # fulltext calls to the search, so we pass it around.
          base_scope = self

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
            query_model.filter.apply(self, base_scope) do |filter|
              has_sort = true if filter.filter_type.is_a?(Search::SortFilter)
            end
          end

          paginate page: options[:page] || 1, per_page: model.default_per_page
          unless has_sort
            begin
              order_by :id, :desc
              # Only order by ID if it happens to be indexed (and we didn't already order_by)
            rescue Sunspot::UnrecognizedFieldError => _
            end
          end

          instance_eval(&block) if block_given?
        end
      end

      SearchList.new(models)
    end

    private

    def fulltext_from_args(args, query_model)
      args.first.is_a?(String) ? args.first : query_model.default_fulltext
    end

    def field_from_args(args)
      return args.first if args.size == 1

      model_name = if args.first.is_a? Class
          args.first.name.to_sym
        else
          args.first.to_sym
        end
      field_name = args[1].to_sym
      Field[model_name, field_name]
    end

    def text_fields_at(index)
      if query_models[index] && query_models[index].query_fields.size > 0
        query_models[index].query_fields.map(&:to_h).reduce({}, :merge)
      end
    end

    def name_is_not_empty_if_owned_by_a_user
      if (self.name.nil? || self.name.empty?) && !self.user_id.nil?
        errors.add :name, "cannot be empty if owned by a user"
      end
    end
  end
end
