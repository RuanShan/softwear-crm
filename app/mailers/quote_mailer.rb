class QuoteMailer < ActionMailer::Base
  default from: 'notifications@example.com'

  def email_customer(hash)
    @body = hash[:body]
    @quote = hash[:quote]
    attachments["YourQuote#{@quote.id}.pdf"] = WickedPdf.new.pdf_from_string(
        render_to_string(pdf: 'quote')
    )
    mail(to: 'someone@something.com', subject: hash[:subject])
  end
end
