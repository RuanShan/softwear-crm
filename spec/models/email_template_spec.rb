require 'spec_helper'

describe EmailTemplate, email_template_spec: true, story_265: true do

  it { is_expected.to be_paranoid }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:subject) }

    it { is_expected.to allow_value('Test Name <test@gmail.com>').for(:from) }
    it { is_expected.to_not allow_value('just_email@domain.com').for(:from) }
    it { is_expected.to allow_value('').for(:from) }

    it { is_expected.to allow_value('Test Name <test@gmail.com>').for(:cc) }
    it { is_expected.to_not allow_value('bogus email').for(:cc) }
    it { is_expected.to allow_value('').for(:cc) }

    it { is_expected.to allow_value('Test Name <test@gmail.com>').for(:bcc) }
    it { is_expected.to_not allow_value('two_emails@here.com, another_email@here.com').for(:bcc) }
    it { is_expected.to allow_value('').for(:bcc) }
  end

  let!(:email_template) { create(:valid_email_template) }

end
