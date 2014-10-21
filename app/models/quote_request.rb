class QuoteRequest < ActiveRecord::Base

  belongs_to :salesperson, class_name: User
  has_many :quotes, through: :quote_request_quotes
  has_many :quote_request_quotes
  
  validates :name, :email, :approx_quantity, :status,
            :date_needed, :description, :source, presence: true

  before_validation(on: :create) { self.status = 'pending' if status.nil? }

  def salesperson_id=(id)
    super
    self.status = 'assigned'
  end
end