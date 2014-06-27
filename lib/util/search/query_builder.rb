module Search
  # The Query Builder can be used to create search queries with pretty much the
  # same syntax as Sunspot, so you don't have to deal with associating /
  # configuring all the filters manually.
  # 
  # Most basic filtering stuff works. Check the QueryBuilder spec for examples.
  class QueryBuilder
    class << self
      def build(&block)
        if block_given?
          builder_base = Base.new
          builder_base.instance_eval(&block)
          builder_base
        else
          Base.new
        end
      end

      def search(&block)
        searcher = Searcher.new
        searcher.instance_eval(&block)
        searcher.searches
      end
    end

    class Searcher
      attr_reader :searches
      def on(*models, &block)
        if models.count == 1 && models.first == :all
          on(*Models.all, &block)
        else
          @searches ||= []
          @searches += models.map do |model|
            model.search(&block)
          end
          @searches
        end
      end
    end

    class Base
      attr_accessor :query
      def initialize
        @query = Query.new
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
              raise "Error saving query model!"
            end

            # If we have a block, make a builder and have it apply
            # the filters a filter group, which we add to the query-
            # model.
            if block_given?
              filter_group = FilterGroup.new(all: true)
              filter = Filter.new
              filter.filter_type = filter_group
              [filter_group, filter].each(&:save)

              query_model.filter = filter
              unless query_model.save
                raise "Error saving query model!"
              end

              builder = QueryBuilder.new(query_model, filter)
              builder.instance_eval(&block)
            end

            # Add the query models to the query
            @query.query_models << query_model
          end
          unless @query.save
            raise "Couldn't save the query!"
          end
        end
      end
    end

    class PendingFilter
      def initialize(filter_group, negate, field)
        raise "Field must be a Search::Field" unless field.is_a? Field
        @group = filter_group
        @negate = negate
        @field = field
      end

      [:greater_than, :less_than].each_with_index do |name, i|
        define_method(name) do |value|
          comp = ['>', '<'][i]
          type = FilterType.of @field
          unless type.column_names.include? 'comparator'
            raise "Must be comparable filter type in order to call #{name}."
          end
          @group.filters << Filter.new(type, field: @field.name, 
            value: value, comparator: comp, negate: @negate)
        end
      end

      def method_missing(name, *args, &block)
        raise "`#{name}' is an unsupported modifier"
      end
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

    def method_missing(name, *args, &block)
      raise "`#{name}' is unsupported by QueryBuilder"
    end

    private
    def type_of(field)
      field_of(field).type_names.reject do |e|
        e == :text
      end.first
    end
    def field_of(field)
      Field[@model.name, field]
    end
  end
end