module Search
  class QueryBuilder
    class << self
      def build(&block)
        if block_given?
          builder_base = Base.new
          builder_base.instance_eval(&block)
          builder_base.query
        else
          Query.new
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
      SUPPORTED_FIELD_TYPES = [:double, :float, :date]

      def initialize(filter_group, negate, field)
        raise "Field must be a Search::Field" unless field.is_a? Field
        @group = filter_group
        @negate = negate
        @field = field
      end

      [:greater_than, :less_than].each_with_index do |name, i|
        define_method(name) do |value|
          comp = ['>', '<'][i]
          type = QueryBuilder.filter_type_for(@field)
          unless type.column_names.include? 'comparator'
            raise "Must be comparable filter type in order to call #{name}."
          end
          @group.filters << type.new(field: @field.name, 
            value: value, comparator: comp, negate: @negate)
        end
      end
    end

    def self.filter_type_for(field)
      raise "Field must be a Search::Field" unless field.is_a? Field
      if !(field.type_names & [:double, :float, :integer]).empty?
        NumberFilter
      elsif field.type_names.include? :string
        StringFilter
      elsif field.type_names.include? :date
        DateFilter
      elsif field.type_names.include? :reference
        ReferenceFilter
      elsif field.type_names.include? :boolean
        BooleanFilter
      end
    end

    # The group is assumed to be within the model
    def initialize(query_model, group_filter)
      @model = query_model
      @group = group_filter
    end

    def fields(*args)
      args.each do |field|
        @model.add_field field
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
          @group.filters << QueryBuilder.filter_type_for(field).new(
            field: field.name, value: args.first, negate: negate)
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