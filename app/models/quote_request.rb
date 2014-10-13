class QuoteRequest < ActiveRecord::Base
  validates :name, :email, :approx_quantity,
            :date_needed, :description, :source, presence: true
end