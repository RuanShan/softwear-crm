module ControllerMacros
  def login_user
    before(:each) do
      user = FactoryGirl.create(:user)
      sign_in user
    end
  end
end
