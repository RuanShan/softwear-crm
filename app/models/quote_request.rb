class QuoteRequest < ActiveRecord::Base

  belongs_to :salesperson, class_name: User
  has_many :quotes, through: :quote_request_quotes
  has_many :quote_request_quotes
  
  validates :name, :email, :approx_quantity,
            :date_needed, :description, :source, presence: true

end