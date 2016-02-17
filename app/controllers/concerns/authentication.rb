module Authentication
  extend ActiveSupport::Concern

  class NotSignedInError < StandardError
  end

  included do
    rescue_from NotSignedInError, with: :user_not_signed_in
    rescue_from AuthModel::AuthServerDown, with: :auth_server_down

    helper_method :current_user
    helper_method :user_signed_in?

    helper_method :destroy_user_session_path
    helper_method :users_path
    helper_method :user_path
    helper_method :edit_user_path
  end

  def user_class
    if AuthModel.descendants.size > 1
      raise "More than one descendent of AuthModel is not supported."
    elsif AuthModel.descendants.size == 0
      raise "Please define a user model that extends AuthModel."
    end
    AuthModel.descendants.first
  end

  # ====================
  # Action called when a NotSignedInError is raised.
  # ====================
  def user_not_signed_in
    redirect_to Figaro.env.softwear_hub_url + "/users/sign_in?#{{return_to: request.original_url}.to_param}"
  end

  # ====================
  # Action called when a NotSignedInError is raised.
  # ====================
  def auth_server_down(error)
    respond_to do |format|
      format.html do
        render inline: \
          "<h1>#{error.message}</h1><div>Not all site functions will work until the problem is resolved. "\
          "<a href='javascripr' onclick='history.go(-1);return false;' class='btn btn-default'>Go back.</a></div>"
      end

      format.js do
        render inline: "alert(\"#{error.message.gsub('"', '\"')}\");"
      end
    end
  end

  # ====================
  # Drop this into a before_filter to require a user be signed in on every request -
  # just like in Devise.
  # ====================
  def authenticate_user!
    token = session[:user_token]

    if token.blank?
      raise NotSignedInError, "No token"
    end

    if user = user_class.auth(token)
      @current_user = user
    else
      session[:user_token] = nil
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
    user_id = user.is_a?(user_class) ? user.id : user
    Figaro.env.softwear_hub_url + "/users/#{user_id}"
  end

  def edit_user_path(user)
    user_id = user.is_a?(user_class) ? user.id : user
    Figaro.env.softwear_hub_url + "/users/#{user_id}/edit"
  end

  def users_path
    Figaro.env.softwear_hub_url + "/users"
  end
end
