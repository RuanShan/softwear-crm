class User < ActiveRecord::Base
  acts_as_paranoid
  acts_as_token_authenticatable

  attr_encrypted :freshdesk_password, key: 'h4rdc0ded1337ness'

  devise(:database_authenticatable, :confirmable, :recoverable, :registerable,
         :rememberable, :trackable, :timeoutable, :validatable, :lockable)

  belongs_to :store
  has_many :orders
  has_many :search_queries, class_name: 'Search::Query'

  validates :email, email: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :freshdesk_email, email: true, allow_blank: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
