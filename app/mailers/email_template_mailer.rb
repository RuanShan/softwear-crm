class EmailTemplateMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  #
  # Delivers an email template to one or more receivers
  #
  # TODO: need some way of ensuring a user can't try to use an associated model
  # in the body of the email without actually associating a model with it
  def email_template(to, email_template, options = {})
    cc =    options.has_key?(:cc) ? options[:cc] : ''
    bcc =   options.has_key?(:bcc) ? options[:bcc] : ''
    @body = email_template.render(options)
    mail(subject: email_template.subject,
         to: to,
         from: email_template.from,
         cc: cc,
         bcc: bcc,
         sent_on: Time.now)
  end
end
