class Artwork < ActiveRecord::Base
  paginates_per 100

  acts_as_paranoid
  acts_as_taggable

  after_initialize :init_assets

  belongs_to :artist, class_name: User
  has_and_belongs_to_many :artwork_requests
  has_one :artwork, as: :assetable, class_name: Asset, dependent: :destroy
  has_one :preview, as: :assetable, class_name: Asset, dependent: :destroy
  accepts_nested_attributes_for :artwork, allow_destroy: true
  accepts_nested_attributes_for :preview, allow_destroy: true

  validates :name, presence: true
  validates :description, presence: true
  # FIXME
  # validates_attachment_content_type :artwork, :content_type => /^image\/(png|gif|jpeg)/
  # validates_format_of :artwork, :with => %r{\.(png|jpg|gif)\z}i, :message => "must be a .jpg, .png, or .gif"
  # validates_format_of :preview, :with => %r{\.(ai|psd)}i, :message => "must be a .ai or .psd"

  searchable do
    text :name, :description
    text :tag_list do
      tag_list.map(&:to_s)
    end
  end

  private

  def init_assets
    # TODO: see if you need self here
    self.artwork ||= Asset.new if self.new_record?
    self.preview ||= Asset.new if self.new_record?
  end
end
