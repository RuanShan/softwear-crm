require 'spec_helper'

describe User, user_spec: true do
  describe '.customer', customer: true do
    it "returns a user with the email address 'customer@softwearcrm.com' and #customer? is true" do
      expect(User.customer.email).to eq 'customer@softwearcrm.com'
      expect(User.customer.customer?).to eq true
    end
  end

  describe 'when the authentication server goes down for some time' do
    before(:each) do
      User.email_when_down_after 5.seconds
    end

    it 'sends an email', no_ci: true do
      allow(User).to receive(:raw_query).and_return 'response'
      expect(User.query('test1')).to eq 'response'
      expect(User.auth_server_down?).to eq false

      User.expire_query_cache
      allow(User).to receive(:raw_query).and_raise User::AuthServerDown
      expect(User.query('test1')).to eq 'response'
      expect(User.auth_server_down?).to eq true

      sleep 6.seconds

      expect(ErrorReportMailer).to receive(:auth_server_down)
        .and_return double('mail', deliver_now: true)
      User.query('test1')
    end
  end
end
