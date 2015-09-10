class InStoreCredit < ActiveRecord::Base
  validates :name, :customer_email, :amount, :description, :user_id, :valid_until, presence: true
  validates :name, uniqueness: true

  belongs_to :user

  searchable do
    text :name, :customer_name, :tokenize_email, :description

    boolean :used
    integer :id
    date :valid_until
  end

  def customer_name
    "#{customer_first_name} #{customer_last_name}"
  end

  def used?
    # TO BE IMPLEMENTED
    false
  end
  alias_method :used, :used?

  def tokenize_email
    customer_email.gsub(/[@\.]/, ' ')
  end
end
