class Artwork < ActiveRecord::Base
  include Softwear::Auth::BelongsToUser

  acts_as_paranoid
  acts_as_taggable

  paginates_per 100

  searchable do
    text :name, :description
    text :tag_list do
      tag_list.map(&:to_s)
    end
    integer :id
  end

  after_initialize :initialize_assets

  belongs_to_user_called :artist
  belongs_to :artwork, class_name: Asset, dependent: :destroy
  belongs_to :preview, class_name: Asset, dependent: :destroy
  has_many :artwork_request_artworks
  has_many :artwork_requests, through: :artwork_request_artworks
  has_many :artwork_proofs
  has_many :proofs, through: :artwork_proofs

  accepts_nested_attributes_for :artwork, allow_destroy: true
  accepts_nested_attributes_for :preview, allow_destroy: true

  validates :local_file_location,
            :name,
            :description,
            :artwork,
            :preview, presence: true

  def self.fba_missing
    where(name: 'FBA Art Not Provided').first
  end

  def path
    if Figaro.env.artwork_view_host
      "#{Figaro.env.artwork_view_host}/artworks/#{id}/full_view"
    else
      preview.file.url
    end
  end

  def thumbnail_path
    if Figaro.env.artwork_view_host
      "#{Figaro.env.artwork_view_host}/artworks/#{id}/full_view?style=thumb"
    else
      preview.file.url(:thumb)
    end
  end

  private

  def initialize_assets
    set_assetable = proc { |artwork| artwork.assetable = self }
    if Rails.env.test?
      self.artwork ||= Asset.new(allowed_content_type: "^image/(ai|pdf|psd)").tap(&set_assetable)
    else
      self.artwork ||= Asset.new(allowed_content_type: "^image/(ai|pdf|psd|png|gif|jpeg|jpg)").tap(&set_assetable)
    end
    self.preview ||= Asset.new(allowed_content_type: "^image/(png|gif|jpeg|jpg)").tap(&set_assetable)
  end
end
