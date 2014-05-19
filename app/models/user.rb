class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable, :recoverable, :registerable,
          :rememberable, :trackable, :timeoutable, :validatable, :lockable

  has_many :orders

  validates_presence_of :firstname, :lastname, :email
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
end
