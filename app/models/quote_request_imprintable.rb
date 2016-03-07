class QuoteRequestImprintable < ActiveRecord::Base
  belongs_to :quote_request
  belongs_to :imprintable
end
