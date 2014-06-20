module Search
  class Query < ActiveRecord::Base
    belongs_to :user
    has_many :query_models, class_name: 'Search::QueryModel'

    
  end
end