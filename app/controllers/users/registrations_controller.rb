class Users::RegistrationsController < Devise::RegistrationsController
   def create
    devise_parameter_sanitizer.sanitize(:sign_up)
    user_fields = params[:user]
    password = Devise.friendly_token.first 8

    # TODO make this User.new instead
    user = User.create!(user_fields.merge({password: password, 
                              password_confirmation: password}))
    # TODO send email with generated password
    puts '************************************'
    msg = "User created with email #{email} and password #{password}"
    puts msg
    puts '************************************'

    flash[:success] = msg
    redirect_to 'users/sign_in'
  end
end