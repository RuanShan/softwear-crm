class Asset < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :assetable, polymorphic: true
  has_attached_file :file

  validates_attachment_presence :file
  validates_attachment_size :file, less_than: 120.megabytes, if: -> {class==ArtworkRequest}
  validates :description, presence: true

end