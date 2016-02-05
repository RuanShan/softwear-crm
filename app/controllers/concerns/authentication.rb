module Authentication
  extend ActiveSupport::Concern

  class NotSignedInError < StandardError
  end

  included do
    rescue_from NotSignedInError, with: :user_not_signed_in
    helper_method :current_user
    helper_method :user_signed_in
    helper_method :destroy_user_session_path
    helper_method :user_path
  end

  def user_not_signed_in
    redirect_to Figaro.env.softwear_hub_url + "/users/sign_in?#{{return_to: request.original_url}.to_param}"
  end

  protected

  def authenticate_user!
    token = session[:user_token]

    if token.blank?
      raise NotSignedInError, "No token"
    end

    if user = User.auth(token)
      @current_user = user
    else
      raise NotSignedInError, "Invalid token"
    end
  end

  def current_user
    @current_user
  end

  def user_signed_in?
    !@current_user.nil?
  end

  # -- url uelpers --

  def destroy_user_session_path
    Figaro.env.softwear_hub_url + "/users/sign_out"
  end

  def user_path(user)
    user_id = user.is_a?(User) ? user.id : user
    Figaro.env.softwear_hub_url + "/users/#{user_id}"
  end

  def edit_user_path(user)
    user_id = user.is_a?(User) ? user.id : user
    Figaro.env.softwear_hub_url + "/users/#{user_id}/edit"
  end
end
