module Search
  class Query < ActiveRecord::Base
    belongs_to :user
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
    def filter_for(*args)
      field = field_from_args(args)

      return nil if field.nil?

      query_model = query_models.find do |m|
        m.name.to_sym == field.model_name.to_sym
      end

      return nil if query_model.nil?

      filter = query_model.filter

      if filter.type.is_a?(FilterGroup)
        return filter.type.find_field(field)
      else
        return filter if filter.field.to_sym == field.name.to_sym
      end
      nil
    end

    # Here it is. The almighty search function. Stuff like this gets a little
    # hairy, due to the nature of Sunspot's DSL. If you're unfamiliar with
    # how Sunspot looks in action, check out https://github.com/sunspot/sunspot.
    #
    # You may notice that Sunspot works similar to RSpec, in that is looks
    # very english and reads well. Technically speaking, however, it's a bit
    # odd, since somehow the 'with' and 'all_of' etc. methods are all of a
    # sudden available even though you never defined them or included them.
    # This is because it uses instance_eval(&block), which actually sets the
    # context (self) for the block body.
    # Here's an example of what this can do:
    #
    # a = [1, 2, 3].join(', ')
    # # is equivalent to:
    # a = [1, 2, 3].instance_eval { join(', ') }
    #
    # In the second part, the context of the { join(', ') } block is set
    # to the array. Here's another interesting example.
    # Consider this method definition:
    #
    # def something
    #   'man'
    # end
    #
    # Now, let's do this:
    #
    # str = "hey there ".concat(something)
    #
    # Kind of stupid, but it would assign str to "hey there man".
    # Now, let's try using instance_eval like in the last example
    # to make it even more stupid:
    #
    # str = "hey there ".instance_eval { concat(something) }
    #
    # This would actually raise a NoMethodError, because 'something' is
    # not defined within String. This is largely why it's inevidably
    # messy to interact with these DSL procs required for Sunspot.
    # It seems impossible to do anything dynamic since you can't access
    # your methods, but oddly enough, local variables actually do carry
    # over:
    #
    # local_thing = something
    # str = "hey there ".instance_eval { concat(local_thing) }
    #
    # That will actually have the desired effect, dang!
    #
    # As much as it is pretty cool that we can carry over our data, it
    # makes it difficult to split up our functionality into functions
    # after a certain point.
    #
    # QueriesController contains an interesting workaround that may
    # be hard to grasp at first, but is much easier to work with
    # once you do.
    # (psych it's confusing as piss always)
    def search(*args, &block)
      options = args.last.is_a?(Hash) ? args.last : {}

      models = self.models.map.with_index do |model, i|
        # Locals to be used inside search DSL block.
        text_fields = text_fields_at(i)
        query_model = query_models[i]
        base_scope  = nil
        text        = fulltext_from_args(args, query_model)

        # It begins!
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
            query_model.filter.apply(self, base_scope)
          end

          instance_eval(&block) if block_given?
          paginate page: options[:page] || 1, per_page: model.default_per_page
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
