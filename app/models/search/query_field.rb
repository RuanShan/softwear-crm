module Search
  class QueryField < ActiveRecord::Base
    belongs_to :query_model, class_name: 'Search::QueryField'
  end
end