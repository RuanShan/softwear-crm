class TemplateMailer < ActionMailer::Base

  #
  # Delivers an email template to one or more receivers
  #
  def email_template(to, email_template, options = {})
    subject email_template.subject
    recipients to
    from email_template.from
    sent_on Time.now
    cc options['cc'] if options.key?('cc')
    bcc options['bcc'] if options.key?('bcc')
    body body: email_template.render(options)
  end
end
