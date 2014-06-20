module Search
  class QueryField < ActiveRecord::Base
    belongs_to :query_model, class_name: 'Search::QueryModel'

    def to_h
      {self.name => self.boost || 1}
    end

    def to_field
      Field[query_model.name, self.name]
    end

    private
  end
end