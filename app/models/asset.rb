class Asset < ActiveRecord::Base
  acts_as_paranoid

  attr_accessor :photo

  path = if Paperclip::Attachment.default_options[:storage] == :s3
           '/public/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension'
         else
           ":rails_root/public/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension"
         end

  url = if Paperclip::Attachment.default_options[:storage] == :s3
          '/public/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension'
        else
          '/assets/:assetable_type/:assetable_id/asset/:style/:id.:extension'
        end

  belongs_to :assetable, polymorphic: true

  validates :description, presence: true

  has_attached_file :file,
                    path: path,
                    url: url,
                    styles: { icon: ['100x100#'], thumb: ['200x200>'], medium: ['250x250>'], large: ['500x500>'], signature: ['300x300>'] }
  validates_attachment :file, presence: true,
            size: { less_than: 120.megabytes },
    content_type: { content_type: ->(_, a) { Regexp.new(a.allowed_content_type) } },
              if: :content_type_restricted?

  do_not_validate_attachment_file_type :file, unless: :content_type_restricted?

  def file_url=(new_file_url)
    self.file = new_file_url unless new_file_url.blank?
  end

  def file_url
    nil
  end

  def content_type_restricted?
    !allowed_content_type.blank?
  end
end
