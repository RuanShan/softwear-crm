class UsersController < ApplicationController
  before_action :set_current_action
  skip_before_filter :authenticate_user!, only: [:set_session_token]

  def set_session_token
    token = params[:token]
    redirect_to root_path if token.blank?

    session[:user_token] = token

    render inline: 'Done'
  end

  private

  def set_current_action
    @current_action = 'users'
  end
end
