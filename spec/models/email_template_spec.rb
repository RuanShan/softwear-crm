require 'spec_helper'

describe EmailTemplate, email_template_spec: true, story_265: true do

  it { is_expected.to be_paranoid }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:template_type) }
    it { is_expected.to validate_presence_of(:to) }
    it { is_expected.to validate_presence_of(:plaintext_body) }
    it { is_expected.to validate_presence_of(:from) }
  end

end
