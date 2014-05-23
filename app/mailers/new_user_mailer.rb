class NewUserMailer < ActionMailer::Base
  default from: "support@softwearcrm.com"

  def confirm_user(new_user, password, granter)
  	@user = new_user
  	@password = password
  	@granter = granter
    mail to: new_user.email, subject: 'Your new Ann Arbor Tees admin account!'
  end
end
