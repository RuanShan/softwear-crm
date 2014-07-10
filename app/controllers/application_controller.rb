class ApplicationController < ActionController::Base
  include PublicActivity::StoreController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_user_parameters, if: :devise_controller?
  # These allow current_user and the current url to be available to views
  before_action :assign_current_user
  before_action :assign_current_url

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

  def assign_current_url
    @current_url = request.original_url
  end

  def with_format(format)
    old_formats = formats
    self.formats = [format]
    r = yield
    self.formats = old_formats
    r
  end

  def last_search
    session[:last_search]
  end
end
