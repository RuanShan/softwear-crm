class Asset < ActiveRecord::Base
  acts_as_paranoid

  path = if Paperclip::Attachment.default_options[:storage] == :s3
           '/public/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension'
         else
           "#{Rails.root}/public/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension"
         end

  url = if Paperclip::Attachment.default_options[:storage] == :s3
          '/public/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension'
        else
          '/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension'
        end

  belongs_to :assetable, polymorphic: true

  validates :description, presence: true

  do_not_validate_attachment_file_type :file
  has_attached_file :file,
                    path: path,
                    url: url,
                    styles: { thumb: ['100x100#'], medium: ['250x250#'] }
  validates_attachment_presence :file
  validates_attachment_size :file, less_than: 120.megabytes
end
