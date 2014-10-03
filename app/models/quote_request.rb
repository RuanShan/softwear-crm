class QuoteRequest < ActiveRecord::Base
  belongs_to :salesperson, class_name: User
end