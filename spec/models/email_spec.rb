require 'spec_helper'
include ApplicationHelper

describe Email, email_spec: true, story_74: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:emailable) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:plaintext_body) }
    it { is_expected.to validate_presence_of(:to) }
    it { is_expected.to validate_presence_of(:from) }
    it { is_expected.to validate_presence_of(:emailable) }
  end
end