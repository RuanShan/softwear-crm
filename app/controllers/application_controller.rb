class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_user_parameters, if: :devise_controller?

protected
  def configure_user_parameters
    sanitizer = devise_parameter_sanitizer.for(:sign_up)
    sanitizer << :firstname
    sanitizer << :lastname
  end
end
