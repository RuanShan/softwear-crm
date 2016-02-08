module SpecAuth
  def stub_authentication!
    Thread.current[:users] = []

    allow(User).to receive(:all) { Thread.current[:users].to_json }
  end
end
