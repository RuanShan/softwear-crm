class NewUserMailer < ActionMailer::Base
  default from: 'noreply@softwearcrm.com'

  def confirm_user(hash)
  	@user = hash[:new_user]
  	@password = hash[:password]
  	@granter = hash[:granter]

    mail to: hash[:new_user].email, subject: 'Your new Ann Arbor Tees admin account!'
  end
end
