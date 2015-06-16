module Search
  # The Query Builder can be used to create search queries with pretty much the
  # same syntax as Sunspot, so you don't have to deal with associating /
  # configuring all the filters manually.
  #
  # Most basic filtering stuff works. Check the QueryBuilder spec for examples.
  class QueryBuilder
    class << self
      def build(query_or_name=nil, &block)
        if block_given?
          builder_base = Base.new(query_or_name)
          builder_base.instance_eval(&block)
          builder_base
        else
          Base.new(query_or_name)
        end
      end

      def search(options={}, &block)
        searcher = Searcher.new(options)
        searcher.instance_eval(&block)
        searcher.searches
      end
    end

    class Searcher
      attr_reader :searches
      def initialize(options)
        @options = options
      end

      def on(*models, &block)
        options = @options

        if models.count == 1 && models.first == :all
          on(*Models.all, &block)
        else
          @searches ||= []
          @searches += models.map do |model|
            next if model.is_a?(Hash)
            model.search do
              instance_eval(&block)
              paginate page: options[:page] || 1, per_page: model.default_per_page

              order_by options[:sort], options[:ordering] if options[:sort]
            end
          end
          @searches.flatten.compact
        end
      end
    end

    class Base
      attr_accessor :query
      def initialize(query_or_name)
        @query = if query_or_name
          case query_or_name
          when Search::Query
            query_or_name.query_models.each(&:destroy)
            query_or_name.query_models.clear
            query_or_name
          when String
            Query.new name: query_or_name
          end
        else
          Query.new
        end
      end

      # For now, assuming no duplicates will be added.
      def on(*models, &block)
        if models.count == 1 && models.first == :all
          on(*Models.all, &block)
        else
          models.each do |model|
            model_name = if model.is_a? Class
              model.name; else; model.to_s
            end

            # Create the query model.
            query_model = QueryModel.new(name: model_name)

            unless query_model.save
              raise SearchException.new "Error saving query model!"
            end

            # If we have a block, make a builder and have it apply
            # the filters to a filter group, which we add to the
            # query model.
            if block_given?
              filter_group = FilterGroup.new(all: true)
              filter = Filter.new
              filter.filter_type = filter_group
              [filter_group, filter].each(&:save)

              query_model.filter = filter
              unless query_model.save
                raise SearchException.new "Error saving query model!"
              end

              builder = QueryBuilder.new(query_model, filter)
              builder.instance_eval(&block)
            end

            # Add the query models to the query
            @query.query_models << query_model
          end
          unless @query.save
            raise SearchException.new "Couldn't save the query! #{@query.errors.full_messages.join(', ')}"
          end
        end
      end
    end

    class PendingFilter
      def initialize(filter_group, negate, field)
        raise SearchException.new "Field must be a Search::Field" unless field.is_a? Field
        @group = filter_group
        @negate = negate
        @field = field
      end

      [:greater_than, :less_than].each_with_index do |name, i|
        define_method(name) do |value|
          comp = ['>', '<'][i]
          type = FilterType.of @field
          unless type.uses_comparator?
            raise SearchException.new "Must be comparable filter type in order to call #{name}."
          end
          @group.filters << Filter.new(type, field: @field.name,
            value: value, comparator: comp, negate: @negate)
        end
      end

      def method_missing(name, *args, &block)
        raise SearchException.new "`#{name}' is an unsupported modifier"
      end
    end

    class PendingPhrase
      def initialize(&block)
        instance_eval(&block)
      end

      def fields(*args)
        @fields = args
      end

      def grab_fields; @fields; end
    end

    # The group is assumed to be within the model
    def initialize(query_model, group_filter)
      @model = query_model
      @group = group_filter
    end

    def fields(*args)
      args.each do |field|
        if field.is_a? Hash
          field.each do |name, boost|
            @model.add_field name, boost
          end
        else
          @model.add_field field
        end
      end
    end

    [:with, :without].each do |name|
      define_method(name) do |field_name, *args|
        negate = name == :without
        field = field_of field_name
        if field.nil?
          raise SearchException, "#{@model.name} has no field called #{field_name}."
        end

        case args.count
        when 0
          return PendingFilter.new(@group, negate, field)
        when 1
          type = FilterType.of field
          @group.filters << Filter.new(type, field: field.name,
            value: args.first, negate: negate)
        end
      end
    end

    # any_of and all_of add FilterGroups to the builder's group
    [:any_of, :all_of].each do |name|
      define_method(name) do |&block|
        all = name == :all_of

        filter_group = FilterGroup.new(all: all)
        filter = Filter.new
        filter.filter_type = filter_group
        [filter_group, filter].each(&:save)

        @group.filters << filter
        QueryBuilder.new(@model, filter).instance_eval(&block)
      end
    end

    def fulltext(text, &block)
      @model.default_fulltext = text
      instance_eval(&block) if block_given?
    end
    # Keywords is used separately from fulltext to associate with
    # phrase filters.
    def keywords(text, &block)
      phrase = PendingPhrase.new(&block)
      fields = phrase.grab_fields

      case fields.size
      when 0
        raise SearchException, "Phrase filters must specify a field"
      when 1
        filter = Filter.new(
          PhraseFilter,
          field: fields.first,
          value: PhraseFilter.assure_value(text)
        )
        @group.filters << filter
      else
        raise SearchException, "Phrase filters can currently only handle 1 field"
      end
    end

    def method_missing(name, *args, &block)
      raise SearchException, "`#{name}' is unsupported by QueryBuilder"
    end

    private
    def type_of(field)
      field_of(field).type_names.reject { |e| e == :text }.first
    end

    def field_of(field)
      Field[@model.name, field]
    end
  end
end
