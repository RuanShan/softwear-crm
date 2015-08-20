class Proof < ActiveRecord::Base
  include TrackingHelpers

  acts_as_paranoid

  tracked by_current_user + on_order

  VALID_PROOF_STATUSES = [
      'Pending',
      'Emailed Customer',
      'Approved',
      'Rejected'
  ]

  belongs_to :order
  belongs_to :job
  has_many :artwork_proofs
  has_many :artworks, through: :artwork_proofs
  has_many :mockups, as: :assetable, class_name: Asset, dependent: :destroy

  accepts_nested_attributes_for :mockups, allow_destroy: true

  validates :approve_by, presence: true
  validates :artworks, presence: true
  validates :status, presence: true

  def artwork_paths
    artworks.map do |artwork|
      artwork.artwork.file.url
    end
  end
  def artwork_thumbnail_paths
    artworks.map do |artwork|
      artwork.artwork.file.url(:thumb)
    end
  end

  def mockup_paths
    mockups.map do |mockup|
      mockup.file.url
    end
  end
  def mockup_thumbnail_paths
    mockups.map do |mockup|
      mockup.file.url(:thumb)
    end
  end
end
