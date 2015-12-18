class Users::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token, only: :create

  def create
    super do |resource|
      if current_user
        if session[:lock] && session[:lock][:email] == current_user.email
          location = session[:lock][:location] || root_path
          session[:lock] = nil
          return redirect_to location
        end
      end
    end
  end

  def new
    @lock = session[:lock] if session[:lock]
    super
  end
end
