class QuoteRequestMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  def notify_sales_of_bad_quote_requests(errors)
    @errors = errors
    mail(to: 'sales@annarbortees.com', subject: "Bad Quotes Requests within Wordpress #{Time.now.strftime('%Y-%m-%d %H:%M')}")

  end
end
