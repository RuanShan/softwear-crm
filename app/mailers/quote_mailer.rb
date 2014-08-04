class QuoteMailer < ActionMailer::Base
  def email_customer(hash)
    @body = hash[:body]
    @quote = hash[:quote]

    attachments["YourQuote#{@quote.id}.pdf"] =
      WickedPdf.new.pdf_from_string(
        render_to_string(pdf: 'quote', partial: 'quotes/email_line_items.html.erb')
      )

    mail(from: hash[:from], to: hash[:to], subject: hash[:subject])
  end
end
