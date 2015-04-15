require 'spec_helper'

describe QuoteRequest, quote_request_spec: true, story_78: true do
  let(:quote_request) { create :quote_request }

  describe 'Fields' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    # it { is_expected.to have_db_column(:approx_quantity).of_type(:decimal) }
    it { is_expected.to have_db_column(:date_needed).of_type(:datetime) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:source).of_type(:string) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

    it { is_expected.to have_db_column(:status).of_type(:string) }
  end

  describe 'Validations' do
    context 'when status == "could_not_quote"', story_472: true do
      before { subject.status = 'could_not_quote' }
      it { is_expected.to validate_presence_of :reason }
    end
    context 'when status != "could_not_quote"', story_472: true do
      before { subject.status = 'pending' }
      it { is_expected.to_not validate_presence_of :reason }
    end
  end

  describe 'Insightly', story_513: true do
    context 'when assigned' do
      it 'finds an insightly contact with an email matching the supplied email' do
        dummy_contact = Object.new
        dummy_client = Object.new
        expect(dummy_client).to receive(:get_contacts)
          .with(email: 'test@test.com')
          .and_return [dummy_contact]

        expect(dummy_contact).to receive(:contact_id).and_return 123

        allow(subject).to receive(:insightly).and_return dummy_client

        subject.salesperson_id = create(:user).id
        subject.save
        expect(subject.insightly_contact_id).to eq 123
      end
    end
  end

  describe 'status', story_195: true do
    context 'on creation' do
      it 'is "pending"' do
        quote_request = QuoteRequest.create(
          name: 'cool guy',
          email: 'cool@guy.com',
          approx_quantity: 15,
          date_needed: Time.now + 2.weeks,
          description: 'Hey man, I need some SHIRTS',
          source: 'RSpec'
        )
        expect(quote_request).to be_valid
        expect(quote_request.status).to eq 'pending'
      end
    end
  end

  describe '#salesperson_id=', story_195: true do
    let!(:user) { create(:user) }

    it 'sets status to "assigned"' do
      quote_request.salesperson_id = user.id
      quote_request.save
      expect(quote_request.reload.status).to eq 'assigned'
    end
  end

  describe 'when status is changed', story_271: true do
    it 'creates a public activity with params s: status_changed_from/to' do
      quote_request.status = 'requested_info'
      PublicActivity.with_tracking do
        quote_request.save
        activity = quote_request.activities.first

        expect(activity.parameters[:s]).to be_a Hash
        expect(activity.parameters[:s][:status_changed_from]).to eq 'pending'
        expect(activity.parameters[:s][:status_changed_to]).to eq 'requested_info'
      end
    end
  end
end
