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
        raise "Model #{searchable_model.name} is not searchable!" unless searchable_model.searchable?
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
    if name.is_a? Class
      Models[name.name]
    else
      Models[name]
    end
  end
  class Field
    attr_reader :name
    attr_reader :type_name
    attr_reader :model_name

    def initialize(model_name, name, type_name)
      @name = name
      @type_name = type_name
      @model_name = model_name
    end

    # def ==(other)
    #   return super(other) unless other.is_a? Field
    #   other.name       == self.name &&
    #   other.type_name  == self.type_name &&
    #   other.model_name == self.model_name
    # end
    # def !=(other)
    #   return super(other) unless other.is_a? Field
    #   other.name       != self.name ||
    #   other.type_name  != self.type_name ||
    #   other.model_name != self.model_name
    # end
  end
end
