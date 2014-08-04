class User < ActiveRecord::Base
  acts_as_paranoid

  # TODO: styling
  devise(:database_authenticatable, :confirmable, :recoverable, :registerable,
         :rememberable, :trackable, :timeoutable, :validatable, :lockable)

  has_many :orders
  belongs_to :store
  has_many :search_queries, class_name: 'Search::Query'

  validates_presence_of :first_name, :last_name
  # TODO: custom validator
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  def full_name
    "#{first_name} #{last_name}"
  end
end
