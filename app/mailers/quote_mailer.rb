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

  # -- NOTE This is unused. Leaving it here just in case. --
  # def create_freshdesk_ticket(quote)
  #   @quote = quote
  #   mail(
  #     from: 'crm@softwearcrm.com',
  #     to: 'makeaticket@annarbortees.freshdesk.com',
  #     subject: 'Created by Softwear-CRM'
  #   )
  # end
end
