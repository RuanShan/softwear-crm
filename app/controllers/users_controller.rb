class UsersController < InheritedResources::Base
  before_action :set_current_action

  def create
    password = Devise.friendly_token.first 8
    user = User.new(sign_up_params.merge(password: password,
                                         password_confirmation: password))

    unless user.valid?
      flash[:alert] = user.errors.include? :email ? 'Email already in use' : 'Error creating user'
      return redirect_to new_user_path
    end

    # TODO perhaps move confirmation elsewhere using skip_confirmation!
    user.confirm!
    user.save

    if user_signed_in?
      hash = {new_user: user, password: password, granter: current_user}
      NewUserMailer.delay.confirm_user(hash)
    else
      flash[:alert] = 'Not signed in!'
      redirect_to '/'
    end

    flash[:notice] = t('user_creation', full_name: user.full_name, email: user.email)
    redirect_to users_path
  end
  
  def update_password
    unless @current_user.update_with_password password_params
      flash[:alert] = 'Error changing password'
      return render :edit_password
    end

    sign_in @current_user, bypass: true
    flash[:notice] = 'Password successfully changed!'
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

  def show
    redirect_to users_path
  end

protected

  def set_current_action
    @current_action = 'users'
  end

private

  def permitted_params
    params.permit(user: [:email, :first_name, :last_name, :store_id,
                         :freshdesk_email, :freshdesk_password,
                         :insightly_api_key])
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
