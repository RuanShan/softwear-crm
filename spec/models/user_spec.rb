require 'spec_helper'

describe User, user_spec: true do
  context 'when validating' do
    it { should validate_presence_of :firstname }
    it { should validate_presence_of :lastname }
    it { should validate_presence_of :email }

    it { should allow_value('test@annarbortees.com').for :email }
    it { should_not allow_value('invalidemail').for :email }
  end
end