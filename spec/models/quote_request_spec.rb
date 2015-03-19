require 'spec_helper'

describe QuoteRequest, quote_request_spec: true, story_78: true do
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
      quote_request = create(:quote_request)
      quote_request.salesperson_id = user.id
      quote_request.save
      expect(quote_request.reload.status).to eq 'assigned'
    end
  end
end
