require 'spec_helper'

describe QuoteMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  before(:all) do
    user = create(:alternate_user)
    store = create(:valid_store)
    quote = Quote.new(
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
        store_id: store.id
    )
    hash = {
        quote: quote,
        body: 'Sample email body',
        subject: 'Amazing Test Subject',
        from: 'from@test.com',
        to: 'to@test.com'
    }
    @email = QuoteMailer.email_customer(hash)
  end

  describe '#email_customer' do
    it 'sets email to be delivered to address passed in via hash[:to]' do
      expect(@email).to deliver_to('to@test.com')
    end

    it 'is sent from the email passed in via hash[:from]' do
      expect(@email).to deliver_from('from@test.com')
    end

    it 'has the subject passed in from hash[:subject]' do
      expect(@email).to have_subject('Amazing Test Subject')
    end

    it 'has the body passed in from hash[:body]' do
      expect(@email).to have_body_text('Sample email body')
    end
  end
end
