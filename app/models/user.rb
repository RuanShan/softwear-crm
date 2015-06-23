class User < ActiveRecord::Base
  acts_as_paranoid
  acts_as_token_authenticatable

  attr_encrypted :freshdesk_password, key: 'h4rdc0ded1337ness'

  devise(:database_authenticatable, :confirmable, :recoverable, :registerable,
         :rememberable, :trackable, :timeoutable, :validatable, :lockable)

  belongs_to :store
  has_many :orders
  has_many :quote_requests, foreign_key: 'salesperson_id'
  has_many :pending_quote_requests, -> {where.not(status: 'quoted')}, foreign_key: 'salesperson_id', class_name: 'QuoteRequest'
  has_many :search_queries, class_name: 'Search::Query'
  belongs_to :profile_picture, class_name: 'Asset'
  belongs_to :signature, class_name: 'Asset'

  accepts_nested_attributes_for :profile_picture
  accepts_nested_attributes_for :signature

  validates :email, email: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :freshdesk_email, email: true, allow_blank: true

  after_save :assign_image_assetables

  def full_name
    "#{first_name} #{last_name}"
  end

  # Don't assign attachment attributes if no file is specified
  [:profile_picture_attributes=, :signature_attributes=].each do |assignment|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{assignment}(attrs)
        super(attrs) unless attrs[:file].blank?
      end
    RUBY
  end

  private

  # We use belongs_to for the images, because you cannot have two has_ones of the
  # same type. Because of this, the assets don't get the assetable information they
  # need for paths. This is a quick fix for that.
  def assign_image_assetables
    [profile_picture, signature].compact.each do |image|
      image.assetable = self
      image.save(validate: false)
    end
  end
end
