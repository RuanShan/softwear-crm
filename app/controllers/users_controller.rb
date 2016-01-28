class UsersController < ApplicationController
  before_action :set_current_action

  def set_session_token
    token = params[:token]
    redirect_to root_path if token.blank?

    cookies[:user_token] = {
      value: token,
      expires: 1.day.from_now
    }

    render inline: 'Done'
  end

end
