class ProofMailer < ActionMailer::Base
  require 'open-uri'

  default from: 'noreply@softwearcrm.com'

  def proof_approval_email(hash)
    @subject = hash[:subject]
    @body = hash[:body]
    @order = hash[:order]
    @proof = hash[:proof]

    @proof.artworks.each do |artwork|
      attach(artwork.preview)
    end

    @proof.mockups.each do |mockup|
      attach(mockup)
    end

    mail(to: @order.email, subject: @subject)
  end

  def attach(attachment)
    storage_type = Paperclip::Attachment.default_options[:storage]
    if storage_type == :s3
      attachments[attachment.file_file_name] = open("#{attachment.file.url}").read
    else
      attachments[attachment.file_file_name] = File.read(attachment.file.path)
    end
  end

  def proof_reminder_email(hash)
    @subject = hash[:subject]
    @body = hash[:body]
    @order = hash[:order]
    @proof = hash[:proof]

    mail(to: @order.email, subject: @subject)
  end
end
