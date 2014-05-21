class UsersController < InheritedResources::Base
  def new
    redirect_to new_user_registration_path
  end

  undef show
end