class Store < ActiveRecord::Base
  acts_as_paranoid

  after_initialize :initialize_logo
  
  has_many :sample_locations
  has_many :imprintable_stores
  has_many :imprintables, through: :imprintable_stores
  belongs_to :logo, class_name: Asset, dependent: :destroy

  accepts_nested_attributes_for :logo, allow_destroy: true

  validates :name, :address_1, :city, :state, :zipcode, :country, :phone, :sales_email, presence: true
  validates :name, uniqueness: true
  

  def address_array
    [address_1, address_2, "#{city}, #{state} #{zipcode}", country].reject(&:blank?)
  end

  private

  def initialize_logo
    self.logo ||= Asset.new(allowed_content_type: "^image/(png|gif|jpeg|jpg)").tap(&set_assetable)
  end

  def set_assetable
    proc { |logo| logo.assetable = self }
  end

end
