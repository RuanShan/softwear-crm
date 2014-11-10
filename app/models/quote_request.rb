class QuoteRequest < ActiveRecord::Base

  paginates_per 100

  searchable do
    text :name, :email, :description, :source, :status
    # TODO implement search for salesperson by name
    # text :salesperson do
    #   salesperson.map{ |person| person.name }
    # end

    string :status
  end

  QUOTE_REQUEST_STATUSES = %w(assigned pending)

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