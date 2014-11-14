class QuoteRequest < ActiveRecord::Base

  default_scope { order('created_at DESC') }

  paginates_per 50

  searchable do
    text :name, :email, :description, :source, :status
    text :salesperson do
      salesperson.try(:name)
    end
    prder
    string :status
  end

  QUOTE_REQUEST_STATUSES = %w(assigned pending quoted)

  belongs_to :salesperson, class_name: User
  has_many :quote_request_quotes
  has_many :quotes, through: :quote_request_quotes
  has_many :orders, through: :quotes

  validates :name, :email, :approx_quantity, :status,
            :date_needed, :description, :source, presence: true

  before_validation(on: :create) { self.status = 'pending' if status.nil? }

  def salesperson_id=(id)
    super
    self.status = 'assigned'
  end
end
