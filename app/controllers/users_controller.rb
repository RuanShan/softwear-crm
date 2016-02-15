class UsersController < AuthController
  before_action :set_current_action

  private

  def set_current_action
    @current_action = 'users'
  end
end
