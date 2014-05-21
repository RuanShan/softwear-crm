class User < ActiveRecord::Base
  devise :database_authenticatable, :confirmable, :recoverable, :registerable,
          :rememberable, :trackable, :timeoutable, :validatable, :lockable

  has_many :orders

  validates_presence_of :firstname, :lastname
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  def full_name
    "#{firstname} #{lastname}"
  end

  # non-deletable stuff
  default_scope -> { where(deleted_at: nil) }
  scope :deleted, -> { unscoped.where.not(deleted_at: nil) }

  def destroyed?
  	!deleted_at.nil?
  end

  def destroy
  	update_attribute(:deleted_at, Time.now)
  end

  def destroy!
  	update_column(:deleted_at, Time.now)
  end
end
