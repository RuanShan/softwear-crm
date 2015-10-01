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
  belongs_to :artwork, class_name: Asset, dependent: :destroy
  belongs_to :preview, class_name: Asset, dependent: :destroy
  has_many :artwork_request_artworks
  has_many :artwork_requests, through: :artwork_request_artworks
  has_many :artwork_proofs
  has_many :proofs, through: :artwork_proofs

  accepts_nested_attributes_for :artwork, allow_destroy: true
  accepts_nested_attributes_for :preview, allow_destroy: true

  validates :name, :description, :artwork_id, :preview_id, presence: true

  after_save :assign_image_assetables

  private

  def initialize_assets
    self.artwork ||= Asset.new(allowed_content_type: "^image/(ai|pdf|psd)")
    self.preview ||= Asset.new(allowed_content_type: "^image/(png|gif|jpeg|jpg)")
  end

  def assign_image_assetables
    return if id.nil?

    [artwork, preview].each do |image|
      next if image.nil? || !image.assetable.nil?

      image.assetable = self
      image.save(validate: false)
    end
  end
end
