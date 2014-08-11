class User < ActiveRecord::Base
  acts_as_paranoid

  devise(:database_authenticatable, :confirmable, :recoverable, :registerable,
         :rememberable, :trackable, :timeoutable, :validatable, :lockable)

  belongs_to :store
  has_many :orders
  has_many :search_queries, class_name: 'Search::Query'

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, email: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
