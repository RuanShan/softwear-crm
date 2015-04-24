class QuoteMailer < ActionMailer::Base

  def email_customer(email)
    @email = email
    mail(
      from:    @email.from,
      to:      @email.to,
      subject: @email.subject,
      cc:      @email.cc,
      bcc:     @email.bcc
    )
  end

  def create_freshdesk_ticket(quote)
    mail(
      from: from,
      to: 'makeaticket@annarbortees.freshdesk.com',
      # TODO ...
    )
  end
end
