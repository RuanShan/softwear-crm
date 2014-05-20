class Users::RegistrationsController < Devise::RegistrationsController
   def create
    password = Devise.friendly_token.first 8

    user = User.new(sign_up_params.merge({password: password, 
                                          password_confirmation: password}))
    unless user.valid?
      if user.errors.include? :email
        flash[:alert] = 'Email already in use'
      else
        flash[:alert] = 'Error creating user'
      end
      return redirect_to '/users/sign_up'
    end
    user.confirm! # TODO perhaps move confirmation elsewhere using skip_confirmation!
    user.save

    if current_user || !Rails.env.development?
      NewUserMailer.confirm_user(user, password, current_user).deliver
    else
      # For debugging use only
      dummy_user = Class.new do
        def firstname; 'Dummy'; end
        def lastname; 'User'; end
      end.new
      NewUserMailer.confirm_user(user, password, dummy_user).deliver
    end

    flash[:notice] = "User successfully created with email #{user.email} and password #{password}"
    redirect_to users_path
  end
end