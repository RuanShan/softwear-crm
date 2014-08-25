module Search
  class QueryModel < ActiveRecord::Base
    belongs_to :query, class_name: 'Search::Query'
    # Query fields represent the fields on which a fulltext will be applied
    # by a Query.
    has_many :query_fields, class_name: 'Search::QueryField',
                            dependent: :destroy
    
    # Generally, the one filter owned by any query_model is either nil or 
    # a filter_group. Although an actual filter works as expected.
    has_one :filter, as: :filter_holder, dependent: :destroy
    validate :model_is_searchable

    def model
      Kernel.const_get name
    end

    def fields
      return model.searchable_fields if query_fields.empty?
      
      query_fields.map { |f| Search::Field[name, f.name] }
    end

    def add_field(field_name, *boost)
      names = query_fields.map(&:name)

      if names.include? field_name
        raise "#{name} query model already has field #{field_name}"
      elsif Field[name, field_name].nil?
        raise "There is no field #{name}##{field_name}"
      elsif !Field[name, field_name].type_names.include? :text
        raise "#{name}##{field_name} is not fulltext!"
      else
        query_fields << QueryField.new(name: field_name, boost: boost.first)
      end
    end

    private

    def model_is_searchable
      unless model.searchable?
        self.errors[:name] = "#{name} is not a searchable model."
      end
    end
  end
end