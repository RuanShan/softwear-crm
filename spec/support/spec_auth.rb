module SpecAuth
  def stub_authentication!(config, *a)
    config.before(:each, *a) do
      @_users = []

      allow(User).to receive(:all)   { @_users }
      allow(User).to receive(:find)  { |n| @_users.find { |u| u.id == n } }
      allow(User).to receive(:auth)  { @_signed_in_user || false }
      allow(User).to receive(:query) { |q| raise "Unstubbed authentication query \"#{q}\"" }
    end

    config.after(:each, *a) do
      @_users = nil
    end
  end

  def sign_in_as(user)
    @_signed_in_user = user
    page.set_rack_session user_token: 'abc123'
  end
end
