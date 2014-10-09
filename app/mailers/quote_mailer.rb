class QuoteMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  def email_customer(hash)
    @body = hash[:body]
    quote = hash[:quote]

    attachments["YourQuote#{quote.id}.pdf"] =
      WickedPdf.new.pdf_from_string(
        render_to_string(pdf: 'quote',
                         partial: 'quotes/line_items_pdf',
                         locals: { quote: quote })
      )

    mail(from: hash[:from], to: hash[:to], subject: hash[:subject], cc: hash[:cc])
  end
end
