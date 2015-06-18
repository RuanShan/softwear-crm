require 'spec_helper'

describe QuoteMailer, quote_spec: true do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:user) { build_stubbed(:alternate_user) }
  let(:store) { build_stubbed(:valid_store) }
  let(:quote) do
    Quote.new(
      email: 'from@from_something.com',
      phone_number: '2489256080',
      first_name: 'dave',
      last_name: 'suckstorff',
      company: 'Ann Arbor T-Shirt Company',
      twitter: 'dsuckstorff',
      name: 'Quote name',
      valid_until_date: Time.now + 1.day,
      estimated_delivery_date: Time.now + 1.day,
      salesperson_id: user.id,
      store_id: store.id,
      shipping: 14.50
    )
  end
  let(:hash) do
    {
      quote: quote,
      body: 'Sample email body',
      subject: 'Amazing Test Subject',
      from: 'from@test.com',
      to: 'to@test.com, to_two@test.com',
      cc: 'current@user.com'
    }
  end
  let(:quote_email) { QuoteMailer.email_customer(OpenStruct.new(hash)) }

  describe '#email_customer' do
    it 'sets email to be delivered to address passed in via hash[:to]' do
      expect(quote_email).to deliver_to('to@test.com, to_two@test.com')
    end

    it 'is sent from the email passed in via hash[:from]' do
      expect(quote_email).to deliver_from('from@test.com')
    end

    it 'has the subject passed in from hash[:subject]' do
      expect(quote_email).to have_subject('Amazing Test Subject')
    end

    it 'has the body passed in from hash[:body]' do
      expect(quote_email).to have_body_text('Sample email body')
    end

    it "cc's the current user" do
      expect(quote_email).to cc_to('current@user.com')
    end
  end

  describe '#create_freshdesk_ticket', story_518: true do
    it ''
  end
end
