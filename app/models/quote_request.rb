class QuoteRequest < ActiveRecord::Base

  belongs_to :salesperson, class_name: User
  
  validates :name, :email, :approx_quantity,
            :date_needed, :description, :source, presence: true
end