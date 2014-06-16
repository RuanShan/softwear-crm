class UsersController < InheritedResources::Base
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
      return redirect_to new_user_path
    end
    user.confirm! # TODO perhaps move confirmation elsewhere using skip_confirmation!
    user.save

    if user_signed_in?
      NewUserMailer.confirm_user(user, password, current_user).deliver
    else
      flash[:alert] = 'Not signed in!'
      redirect_to '/'
    end

    flash[:notice] = "User #{user.full_name} successfully created with email #{user.email}. Their password has been emailed to them."
    redirect_to users_path
  end

  def edit_password

  end

  def update_password
    unless @current_user.update_with_password password_params
      flash[:alert] = 'Error changing password'
      return render :edit_password
    end
    sign_in @current_user, bypass: true
    flash[:notice] = "Password successfully changed!"
    redirect_to users_path
  end

  def lock
    session[:lock] = {
      email: @current_user.email,
      location: if params[:location] && !params[:location].include?(lock_user_path)
                  params[:location]
                else
                  root_path
                end
    }

    sign_out @current_user
    redirect_to new_user_session_path
  end

  def edit
    super
  end

  def show
    redirect_to users_path
  end

private
  def permitted_params
    params.permit(user: [
      :email, :firstname, :lastname, :store_id
    ])
  end

  def resource_name
    'user'
  end

  def sign_up_params
    permitted_params[:user].merge devise_parameter_sanitizer.sanitize(:sign_up)
  end
  def password_params
    params.permit(user: [:password, :password_confirmation, :current_password])[:user]
  end
end