require 'spec_helper'

describe EmailTemplate, email_template_spec: true, story_265: true do

  it { is_expected.to be_paranoid }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:subject) }

    # Email validations
    it { is_expected.to allow_value('test@gmail.com').for(:from) }
    it { is_expected.to_not allow_value('bogus email').for(:from) }
    it { is_expected.to allow_value('').for(:from) }

    it { is_expected.to allow_value('test@gmail.com').for(:cc) }
    it { is_expected.to_not allow_value('bogus email').for(:cc) }
    it { is_expected.to allow_value('').for(:cc) }

    it { is_expected.to allow_value('test@gmail.com').for(:bcc) }
    it { is_expected.to_not allow_value('bogus email').for(:bcc) }
    it { is_expected.to allow_value('').for(:bcc) }
  end

  let!(:email_template) { create(:valid_email_template) }

  describe '#deliver_to' do

  end

  describe '#render' do
    it 'calls render on template with options passed' do
      expect(email_template).to receive_message_chain(:template, :render)
      email_template.render
    end
  end

  describe '#to_s' do
    it 'returns a readable string format of the template' do
      from = email_template.from
      subject = email_template.subject
      body = email_template.body
      expected = "[EmailTemplate] From: #{from}, '#{subject}': #{body}"
      expect(email_template.to_s).to eq(expected)
    end
  end
end
