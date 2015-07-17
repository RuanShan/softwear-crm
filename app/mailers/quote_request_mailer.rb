class QuoteRequestMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  add_template_helper(QuoteHelper)

  def notify_sales_of_bad_quote_requests(errors)
    @errors = errors
    mail(to: 'sales@annarbortees.com',
         subject: "Bad Quotes Requests within Wordpress #{Time.now.strftime('%Y-%m-%d %H:%M')}",
         from: Figaro.env.smtp_user_name )

  end

  def notify_salesperson_of_quote_request_assignment(quote_request)
    @salesperson = quote_request.salesperson
    @quote_request = quote_request

    mail(
      from: Figaro.env.smtp_user_name,
      to: @salesperson.email,
      subject: "You've been assigned quote request ##{@quote_request.id}"
    )
  end
end
