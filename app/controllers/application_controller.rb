class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_user_parameters, if: :devise_controller?
  before_action :assign_current_user, unless: :devise_controller?

protected
  def configure_user_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit :email, :firstname, :lastname
    end
  end

  def assign_current_user
    if current_user
      @current_user = current_user
    else
      @current_user = Class.new do
        def full_name; 'Error User'; end
      end.new
    end
  end
end
