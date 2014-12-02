require 'spec_helper'

describe TemplateMailer, email_template_spec: true, story_265: true do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before(:all) do
    user = build_stubbed(:alternate_user)
    store = build_stubbed(:valid_store)
    email_template = EmailTemplate.new(
      subject: 'Your Test Template!',
      from: 'devteam@annarbortees.com',
      body: 'Your name is {{ user.name }}'
    )
    @email = TemplateMailer.deliver_email_template('davsucks@umich.edu',
                                                    email_template,
                                                    cc: 'test@testing.com',
                                                    bcc: 'something@else.com')
  end

  describe '#deliver_email_template' do
    it 'sets email to be delivered to address passed in via the first argument' do
      expect(@email).to deliver_to 'davsucks@umich.edu'
    end

    it 'is sent from the email passed in via hash[:from]' do
      expect(@email).to deliver_from 'from@test.com'
    end

    it 'has the subject passed in from the template' do
      expect(@email).to have_subject email_template.subject
    end

    it 'has the body passed in from hash[:body]' do
      # TODO: is this coupling between this test and the EmailTemplate tests?
      # TODO: Might want to stub out render
      expect(@email).to have_body_text email_template.render
    end

    it 'cc\'s the address passed to options' do
      expect(@email).to cc_to 'test@testing.com'
    end

    it 'bcc\'s the address passed to options' do
      expect(@email).to bcc_to 'something@else.com'
    end
  end
end
