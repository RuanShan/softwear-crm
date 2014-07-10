class Asset < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :assetable, polymorphic: true
  has_attached_file :file,
                    :path => "#{Rails.root unless !Rails.env.development?}/public/assets/:assetable_type/:assetable_id/asset/:id.:extension"

  do_not_validate_attachment_file_type :file
  validates_attachment_presence :file
  validates_attachment_size :file, less_than: 120.megabytes, if: -> {instance_of? ArtworkRequest}
  validates :description, presence: true

end