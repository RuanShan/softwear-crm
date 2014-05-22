class UsersController < InheritedResources::Base
  def new
    redirect_to new_user_registration_path
  end

  def edit
    @current_user = current_user
    super
  end

  undef show

private
  def permitted_params
    params.permit(user: [
      :email, :firstname, :lastname
    ])
  end
end