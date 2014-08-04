class ProofMailer < ActionMailer::Base
  require 'open-uri'

  default from: 'noreply@softwearcrm.com'

  # TODO: try to refactor as hash
  def proof_approval_email(proof, order, body, subject)
    @subject = subject
    @body = body
    @order = order
    @proof = proof

    @proof.artworks.each do |artwork|
      # TODO: refactor conditional assignment
      if Paperclip::Attachment.default_options[:storage] == :s3
        attachments[artwork.preview.file_file_name] = open("#{artwork.preview.file.url}").read
      else
        # TODO: use url, not path
        attachments[artwork.preview.file_file_name] = File.read(artwork.preview.file.path)
      end
    end

    @proof.mockups.each do |mockup|
      if Paperclip::Attachment.default_options[:storage] == :s3
        attachments[mockup.file_file_name] = open("#{mockup.file.url}").read
      else
        attachments[mockup.file_file_name] = File.read(mockup.file.path)
      end
    end

    mail(to: @order.email, subject: @subject)
  end

  # TODO: try to refactor as hash
  def proof_reminder_email(proof, order, body, subject)
    @subject = subject
    @body = body
    @order = order
    @proof = proof

    mail(to: @order.email, subject: @subject)
  end
end
