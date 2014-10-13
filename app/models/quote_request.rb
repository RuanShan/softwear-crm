class QuoteRequest < ActiveRecord::Base
  has_many :quotes, through: :quote_request_quotes
  has_many :quote_request_quotes
end