class User < ActiveRecord::Base
  acts_as_paranoid

  # TODO: styling
  devise(:database_authenticatable, :confirmable, :recoverable, :registerable,
         :rememberable, :trackable, :timeoutable, :validatable, :lockable)

  belongs_to :store
  has_many :orders
  has_many :search_queries, class_name: 'Search::Query'

  validates :first_name, presence: true
  validates :last_name, presence: true
  # TODO: custom validator
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  def full_name
    "#{first_name} #{last_name}"
  end
end
