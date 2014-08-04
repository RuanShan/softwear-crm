class Asset < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :assetable, polymorphic: true
  # TODO: line length?
  has_attached_file :file,
                    url: Paperclip::Attachment.default_options[:storage] == :s3 ? '/public/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension' : '/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension',
                    path: Paperclip::Attachment.default_options[:storage] == :s3 ? '/public/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension' : "#{Rails.root}/public/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension",
                    styles: { :thumb => ['100x100#'], :medium => ['250x250#'] }

  do_not_validate_attachment_file_type :file
  validates_attachment_presence :file
  validates_attachment_size :file, less_than: 120.megabytes

  validates :description, presence: true
end
