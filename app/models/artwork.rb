class Artwork < ActiveRecord::Base
  acts_as_paranoid
  acts_as_taggable

  paginates_per 100

  searchable do
    text :name, :description
    text :tag_list do
      tag_list.map(&:to_s)
    end
  end

  after_initialize :initialize_assets

  belongs_to :artist, class_name: User
  has_one :artwork, as: :assetable, class_name: Asset, dependent: :destroy
  has_one :preview, as: :assetable, class_name: Asset, dependent: :destroy
  has_many :artwork_request_artworks
  has_many :artwork_requests, through: :artwork_request_artworks
  has_many :artwork_proofs
  has_many :proofs, through: :artwork_proofs

  accepts_nested_attributes_for :artwork, allow_destroy: true
  accepts_nested_attributes_for :preview, allow_destroy: true

  validates :name, presence: true
  validates :description, presence: true

  # TODO: figure out how to validate attachment type
  # validates_attachment_content_type :artwork, :content_type => /^image\/(png|gif|jpeg)/
  # validates_format_of :artwork, :with => %r{\.(png|jpg|gif)\z}i, :message => "must be a .jpg, .png, or .gif"
  # validates_format_of :preview, :with => %r{\.(ai|psd)}i, :message => "must be a .ai or .psd"

  private

  def initialize_assets
    self.artwork ||= Asset.new if new_record?
    self.preview ||= Asset.new if new_record?
  end
end
