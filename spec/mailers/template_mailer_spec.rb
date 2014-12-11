require 'spec_helper'

describe EmailTemplateMailer, email_template_spec: true, story_265: true do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before(:all) do
    email_template = EmailTemplate.new(
      subject: 'Your Test Template!',
      from: 'devteam@annarbortees.com',
      body: 'Your name is {{name}}'
    )
    @email = EmailTemplateMailer.email_template('davsucks@umich.edu',
                                                email_template,
                                                cc: 'test@testing.com',
                                                bcc: 'something@else.com',
                                                name: 'David')
  end

  describe '#email_template' do
    it 'sets email to be delivered to address passed in via the first argument' do
      expect(@email).to deliver_to 'davsucks@umich.edu'
    end

    it 'is sent from the email passed in to EmailTemplate.new' do
      expect(@email).to deliver_from 'devteam@annarbortees.com'
    end

    it 'has the subject passed in from the template' do
      expect(@email).to have_subject 'Your Test Template!'
    end

    it 'has the body passed in to EmailTemplate.new', pending: 'David isn\'t being interpolated' do
      # TODO: is this coupling between this test and the EmailTemplate tests?
      # TODO: Might want to stub out render
      expect(@email).to have_body_text 'Your name is David'
    end

    it 'cc\'s the address passed to options' do
      expect(@email).to cc_to 'test@testing.com'
    end

    it 'bcc\'s the address passed to options' do
      expect(@email).to bcc_to 'something@else.com'
    end
  end
end
