module Search
  class QueryModel < ActiveRecord::Base
    belongs_to :query, class_name: 'Search::Query'
    has_many :query_fields, class_name: 'Search::QueryField', dependent: :destroy
    has_one :filter, as: :filter_holder, dependent: :destroy
    validate :model_is_searchable

    def model
      Kernel.const_get name
    end

    def fields
      if query_fields.empty?
        model.searchable_fields
      else
        query_fields.map { |f| Search::Field[name, f.name] }
      end
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
    def using(s); yield s; end

    def model_is_searchable
      unless model.searchable?
        self.errors[:name] = "#{name} is not a searchable model."
      end
    end
  end
end