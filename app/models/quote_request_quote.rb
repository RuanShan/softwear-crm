class QuoteRequestQuote < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :quote_request
  belongs_to :quote

  validates :quote_request_id, uniqueness: { scope: :quote_id }
end
