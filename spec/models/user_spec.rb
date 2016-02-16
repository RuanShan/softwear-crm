require 'spec_helper'

describe User, user_spec: true do
  describe '.customer', customer: true do
    it "returns a user with the email address 'customer@softwearcrm.com' and #customer? is true" do
      expect(User.customer.email).to eq 'customer@softwearcrm.com'
      expect(User.customer.customer?).to eq true
    end
  end
end
