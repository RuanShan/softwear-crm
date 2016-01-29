class Asset < ActiveRecord::Base
  acts_as_paranoid

  attr_accessor :photo

  unless Rails.env.test?
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
  end

  belongs_to :assetable, polymorphic: true

  validates :description, presence: true, unless: :model_can_be_blank?

  if Rails.env.test?
    has_attached_file :file,
                      styles: { icon: ['100x100#'], thumb: ['200x200>'], medium: ['250x250>'], large: ['500x500>'], signature: ['300x300>'] }
  else
    has_attached_file :file,
                      path: path,
                      url: url,
                      styles: { icon: ['100x100#'], thumb: ['200x200>'], medium: ['250x250>'], large: ['500x500>'], signature: ['300x300>'] }
  end
  validates_attachment :file,
            size: { less_than: 120.megabytes },
    content_type: { content_type: ->(_, a) { Regexp.new(a.allowed_content_type) } },
              if: :content_type_restricted?

  validates_attachment :file, presence: true, unless: :model_can_be_blank?

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

  private
  
  def model_can_be_blank?
    assetable_type == 'Store'
  end
end
