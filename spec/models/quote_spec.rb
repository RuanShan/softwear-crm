require 'spec_helper'

describe Quote, quote_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships', story_74: true, story_79: true do
    it { is_expected.to belong_to(:salesperson).class_name('User') }
    it { is_expected.to belong_to(:store) }
    it { is_expected.to have_many(:emails) }
    it { is_expected.to have_many(:line_item_groups) }
    it { is_expected.to have_and_belong_to_many(:quote_requests) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('test@example.com').for :email }
    it { is_expected.to_not allow_value('not_an-email').for :email }
    it { is_expected.to validate_presence_of(:estimated_delivery_date) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:quote_source) }
    it { is_expected.to validate_presence_of(:salesperson) }
    it { is_expected.to validate_presence_of(:store) }
    it { is_expected.to validate_presence_of(:valid_until_date) }

    describe 'shipping' do
      it { is_expected.to allow_value('123.32').for :shipping }
      it { is_expected.to allow_value('0').for :shipping }
      it { is_expected.to allow_value('9').for :shipping }
      it { is_expected.to allow_value('2.4').for :shipping }
      it { is_expected.to_not allow_value('21.321').for :shipping }
    end
  end

  describe 'callbacks' do
    context 'when supplied with an initialized at time' do
      it 'sets initialized_at to the supplied time', story_86: true do
        time = Time.zone.now + 1.day
        quote = Quote.new(initialized_at: time)
        expect(quote.initialized_at).to eq(time)
      end
    end

    context 'when not supplied with a time' do
      it 'sets initialized_at to time.now', story_86: true do
        format = '%d/%m/%Y %H:%M'
        expected_val = Quote.new.initialized_at.strftime(format)
        test_val = Time.now.strftime(format)
        expect(expected_val).to eq(test_val)
      end
    end
  end

  describe 'instance methods' do
    let!(:quote) { build_stubbed(:valid_quote) }

    describe '#all_activities' do
      it 'queries publicactivity' do
        expect(PublicActivity::Activity).to receive_message_chain(:where, :order)
        quote.all_activities
      end
    end

    describe '#get_freshdesk_ticket', story_70: true, pending: 'Not sure how to implement this yet' do
      it 'does cool things' do
        expect(false).to be_truthy
      end
    end

    describe '#create_freshdesk_ticket', pending: 'Freshdesk is some shite' do
      it 'calls Freshdesk.new and post_tickets with the correct args' do
        freshdesk_info = {
            requester_id: '12345',
            requester_name: 'Test Name',
            group_id: '54321',
            department: 'Testing'
        }
        expect(quote).to receive(:fetch_data_to_h).and_return(freshdesk_info)

        d = double(post_tickets: 'true')
        expect(Freshdesk).to receive(:new).and_return(d)

        post_ticket_args = {
            email: quote.email,
            requester_id: '12345',
            requester_name: 'Test Name',
            source: 2,
            group_id: '54321',
            ticket_type: 'Lead',
            subject: 'Created by Softwear-CRM',
            custom_field: { department_7483: 'Testing' }
        }
        expect(d).to receive(:post_tickets).with(post_ticket_args)

        quote.create_freshdesk_ticket
      end
    end

    describe '#formatted_phone_number' do
      let(:quote) { build_stubbed(:blank_quote, phone_number: '7342742659') }

      it 'returns the phone number formatted as (xxx) xxx-xxxx' do
        expect(quote.formatted_phone_number).to eq('(734) 274-2659')
      end
    end

    describe 'full_name' do
      let(:quote) { build_stubbed(:blank_quote, first_name: 'First', last_name: 'Last') }

      it 'returns the first name and last name separated by a whitespace' do
        expect(quote.full_name).to eq("#{quote.first_name} #{quote.last_name}")
      end
    end

    describe 'line item validation:' do
      context 'a quote without a line item' do
        it 'is invalid' do
          expect{
            create(:valid_quote, line_item_groups: [])
          }
            .to raise_error ActiveRecord::RecordInvalid
        end
      end

      context 'a quote with a line item' do
        it 'is valid' do
          expect{
            create(:valid_quote)
          }
            .to_not raise_error
        end
      end
    end

    # TODO isn't that slow as is, but could possibly refactor to not use create
    context 'has 2 taxable and 2 non-taxable line items', wip: true do
      let!(:line_item) { create(:non_imprintable_line_item) }
      let!(:quote) { create(:valid_quote) }

      before(:each) do
        2.times { quote.default_group.line_items << create(:taxable_non_imprintable_line_item) }
      end

      describe '#line_items_subtotal' do
        it 'returns the sum of each line item\'s price' do
          expected_price = line_item.total_price * 4
          expect(quote.line_items_subtotal).to eq(expected_price)
        end
      end

      describe '#line_items_total_tax' do
        it 'returns the sum of the taxable portion of the quote\'s line items' do
          taxable_portion = (line_item.total_price * 2) * 0.06
          expect(quote.line_items_total_tax).to eq(taxable_portion)
        end
      end

      describe '#line_items_total_with_tax' do
        it 'returns the total of the line items, including tax' do
          taxable_portion = (line_item.total_price * 2) * 0.06
          total_price = line_item.total_price * 4
          expect(quote.line_items_total_with_tax).to eq(taxable_portion + total_price)
        end
      end
    end

    describe '#standard_line_items' do
      context 'the quote has no line items' do
        let(:quote) { build_stubbed(:blank_quote)}

        it 'returns zero' do
        expect(quote.standard_line_items.size).to eq(0)
        end
      end

      context 'the quote has line items' do
        let(:quote) { create(:valid_quote) }

        it 'returns the number of non-imprintable line items (in this case, two)' do
          expect(quote.standard_line_items.size).to eq(2)
        end
      end
    end

    describe '#tax' do
      let(:quote) { build_stubbed(:blank_quote) }

      it 'returns the value for tax' do
        expect(quote.tax).to eq(0.06)
      end
    end

    describe '#response_time', story_86: true  do
      let(:quote) { build_stubbed(:valid_quote, initialized_at: Time.now) }
      context 'when an email hasn\'t been sent yet' do
        it 'responds with nil' do
          expect(PublicActivity::Activity).to receive_message_chain(:where, :order, :first).and_return(nil)
          expect(quote.response_time).to eq("An email hasn't been sent yet!")
        end
      end

      context 'when an email has been sent' do
        HelperResponse = Class.new
        it 'calculates the time between initialization and customer contact' do
          expect(PublicActivity::Activity).to receive_message_chain(:where, :order, :first).and_return(HelperResponse)
          expect(HelperResponse).to receive(:nil?).and_return(false)
          expect(HelperResponse).to receive(:created_at).and_return(Time.now + 1.day)
          expect(quote.response_time).to_not eq("An email hasn't been sent yet!")
        end
      end
    end

    describe '#quote_request_ids=', story_195: true do
      let!(:quote_request) { create(:valid_quote_request_with_salesperson) }
      let!(:quote) { create(:valid_quote) }

      it 'assigns quote_request.status to "quoted"' do
        quote.quote_request_ids = [quote_request.id]
        expect(quote.save).to eq true
        expect(quote_request.reload.status).to eq 'quoted'
      end
    end
  end
end
