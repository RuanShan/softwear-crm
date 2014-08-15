module Search
  def self.table_name_prefix
    'search_'
  end

  class Models
    class << self
      def all
        @all_models.values
      end

      def register(searchable_model)
        @all_models ||= {}
        # unless searchable_model.searchable?
        #   raise "Model #{searchable_model.name} is not searchable!"
        # end
        @all_models[searchable_model.name] = searchable_model
      end

      def respond_to?(name)
        super(name) || @all_models.respond_to?(name)
      end

      def method_missing(name, *args, &block)
        if @all_models.respond_to?(name)
          @all_models.send(name, *args, &block)
        else
          super(name, *args, &block)
        end
      end
    end
  end

  def Model(name)
    name.is_a?(Class) ? Models[name.name] : Models[name]
  end

  # Contains type info about a field within a model.
  class Field
    attr_reader :name
    attr_reader :type_names
    attr_reader :model_name

    def self.new(model_name, name, type_name)
      s = self[model_name, name]
      if s
        s.type_names << type_name.to_sym
        s
      else
        super
      end
    end

    # Fancy access, such as Search::Field[:Order, :name]
    def self.[](model, field_name)
      if model.is_a? Class
        model
      else
        Kernel.const_get(model.to_s.camelize)
      end
        .searchable_fields[field_name.to_sym]
    end

    def initialize(model_name, name, type_name)
      @name       = name.to_sym
      @type_names = [type_name.to_sym]
      @model_name = 
        (model_name.is_a?(Class) ? model_name.name : model_name).to_sym
    end

    def model
      Kernel.const_get @model_name
    end
  end
end
