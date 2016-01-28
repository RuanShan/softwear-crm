module Authentication
  extend ActiveSupport::Concern

  class NotSignedInError < StandardError
  end

  included do
    rescue_from NotSignedInError, with: :user_not_signed_in
  end

  def user_not_signed_in
    redirect_to Figaro.env.softwear_hub_url + "/users/sign_in?return_to=softwear-crm"
  end

  protected

  def authenticate_user!
    token = cookies[:user_token]

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
end
