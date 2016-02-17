module SpecAuth
  def spec_users
    User.instance_variable_get(:@_spec_users)
  end

  def stub_authentication!(config, *a)
    config.before(:each, *a) do
      User.instance_variable_set(:@_spec_users, [])

      allow(User).to receive(:all)   { spec_users }
      allow(User).to receive(:find)  { |n| spec_users.find { |u| u.id == n } }
      allow(User).to receive(:auth)  { @_signed_in_user or false }
      allow(User).to receive(:raw_query) { |q| raise "Unstubbed authentication query \"#{q}\"" }

      if (controller rescue false)
        allow(controller).to receive(:current_user) { @_signed_in_user }
        controller.class_eval { helper_method :current_user }

        allow(controller).to receive(:user_signed_in?) { !!@_signed_in_user }
        controller.class_eval { helper_method :user_signed_in? }

        allow(controller).to receive(:destroy_user_session_path) { '#' }
        controller.class_eval { helper_method :destroy_user_session_path }

        allow(controller).to receive(:users_path) { '#' }
        controller.class_eval { helper_method :users_path }

        allow(controller).to receive(:edit_user_path) { '#' }
        controller.class_eval { protected; helper_method :edit_user_path }
      end
    end

    config.after(:each, *a) do
      User.instance_variable_set(:@_spec_users, nil)
    end
  end

  def sign_in_as(user)
    @_signed_in_user = user

    if respond_to?(:page)
      page.set_rack_session user_token: 'abc123'
    elsif respond_to?(:session)
      session[:user_token] = 'abc123'
    end
  end
  alias_method :sign_in, :sign_in_as
  alias_method :login_as, :sign_in_as
end
