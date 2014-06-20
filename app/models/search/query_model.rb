module Search
  class QueryModel < ActiveRecord::Base
    belongs_to :query, class_name: 'Search::Query'
    has_many :query_fields, class_name: 'Search::QueryField'
    has_one :filter, as: :filter_holder
  end
end