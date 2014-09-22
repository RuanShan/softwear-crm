require 'spec_helper'

describe Quote, quote_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:salesperson).class_name('User') }
    it { is_expected.to belong_to(:store) }
    it { is_expected.to have_many(:line_item_groups) }
    it { is_expected.to have_many(:line_items).through(:line_item_groups) }

    it { is_expected.to accept_nested_attributes_for(:line_items) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('test@example.com').for :email }
    it { is_expected.to_not allow_value('not_an-email').for :email }
    it { is_expected.to validate_presence_of(:estimated_delivery_date) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
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

  describe 'instance methods' do
    let!(:quote) { build_stubbed(:valid_quote) }

    describe '#all_activities' do
      it 'queries publicactivity' do
        expect(PublicActivity::Activity).to receive_message_chain(:where, :order)
        quote.all_activities
      end
    end

    describe '#create_freshdesk_customer' do
      before(:each) do
        d = double(body: 'true')
        parsed_xml = {
            'user' => {
                'name' => 'Test Name',
                'id' => '12345'
            }
        }
        allow(quote).to receive(:post_request_for_new_customer).and_return(d)
        allow(Hash).to receive(:from_xml).and_return(parsed_xml)
      end

      it 'sets the new_hash properly' do
        test_hash = {
            requester_name: 'Test Name',
            requester_id: '12345'
        }

        return_hash = quote.create_freshdesk_customer
        expect(return_hash).to eq(test_hash)
      end
    end

    describe '#create_freshdesk_ticket' do
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

    describe '#fetch_data_to_h' do
      it 'calls both fetch methods' do
        expect(quote).to receive(:fetch_group_id_and_dept)
                         .with(an_instance_of(Hash)).and_return({})
        expect(quote).to receive(:fetch_requester_id_and_name)
                         .with(an_instance_of(Hash))
        quote.fetch_data_to_h
      end
    end

    describe '#fetch_group_id_and_dept' do
      context 'the quote is from the ann arbor store' do
        let(:quote) { build_stubbed(:blank_quote, store: build_stubbed(:blank_store, name: 'Ann Arbor Store')) }

        it 'sets the group id to "86316" and department to "Sales - Ann Arbor"' do
          return_hash = quote.fetch_group_id_and_dept({})
          expect(return_hash[:group_id]).to eq(86316)
          expect(return_hash[:department]).to eq('Sales - Ann Arbor')
        end
      end

      context 'the quote is from the ypsi store' do
        let(:quote) { build_stubbed(:blank_quote, store: build_stubbed(:blank_store, name: 'Ypsilanti Store')) }

        it 'sets the group_id to "86317" and department to "Sales - Ypsilanti"' do
          return_hash = quote.fetch_group_id_and_dept({})
          expect(return_hash[:group_id]).to eq(86317)
          expect(return_hash[:department]).to eq('Sales - Ypsilanti')
        end
      end

      context 'the quote isn\'t from either store' do
        let(:quote) { build_stubbed(:blank_quote, store: build_stubbed(:blank_store, name: 'Bogus Store')) }

        it 'sets the group_id and department to nil' do
          return_hash = quote.fetch_group_id_and_dept({})
          expect(return_hash[:group_id]).to eq(nil)
          expect(return_hash[:department]).to eq(nil)
        end
      end
    end

    describe '#fetch_request_id_and_name' do
      before(:each) do
        expect(URI).to receive(:escape)
      end

      context 'when a customer is found by Freshdesk API' do
        before(:each) do
          response_double = double(body: 'found_customer')
          site_double = double(get: response_double)
          expect(RestClient::Resource).to receive(:new).and_return(site_double)
        end

        it 'sets new_hash using parsed JSON' do
          expect(JSON).to receive_message_chain(:parse, :first).and_return(
            {
              'user' => {
                'name' => 'Test Name',
                'id' => '12345'
              }
            }
          )
          new_hash = quote.fetch_requester_id_and_name({})
          expected_hash = {
              requester_name: 'Test Name',
              requester_id: '12345'
          }
          expect(new_hash).to eq(expected_hash)
        end
      end

      context 'when a customer is not found by Freshdesk API' do
        before(:each) do
          response_double = double(body: '[]')
          site_double = double(get: response_double)
          expect(RestClient::Resource).to receive(:new).and_return(site_double)
        end

        it 'calls create_freshdesk_customer' do
          expected_hash = {
            test_value: 'horray!'
          }
          expect(quote).to receive(:create_freshdesk_customer)
                           .and_return(expected_hash)
          new_hash = quote.fetch_requester_id_and_name({})
          expect(new_hash).to eq(expected_hash)
        end
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

    describe '#has_line_items?' do
      context 'when the quote has no line_items' do
        before(:each) do
          expect(quote).to receive_message_chain(:line_items, :blank?).and_return(true)
        end

        it 'adds an error' do
          quote.has_line_items?
          expect(quote.errors[:base]).to eq(['Quote must have at least one line item'])
        end
      end

      context 'when the quote has line items' do
        before(:each) do
          expect(quote).to receive_message_chain(:line_items, :blank?).and_return(false)
        end

        it 'is free of errors' do
          quote.has_line_items?
          expect(quote.errors[:base]).to eq([])
        end
      end
    end

    # TODO isn't that slow as is, but could possibly refactor to not use create
    context 'has 2 taxable and 2 non-taxable line items', wip: true do
      let!(:line_item) { create(:non_imprintable_line_item) }
      let!(:quote) { create(:valid_quote) }

      before(:each) do
        2.times { quote.line_items << create(:taxable_non_imprintable_line_item) }
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

    describe '#post_request_for_new_customer' do
      it 'creates a connection and interacts with freshdesk\'s api' do
        uri_double = double(request_uri: 'uri', host: 'host', port: 'port')
        connection_double = double

        expect(URI).to receive(:parse).and_return(uri_double)
        expect(Net::HTTP::Post).to receive(:new).and_return({})
        expect_any_instance_of(Hash).to receive(:basic_auth)
        expect(Net::HTTP).to receive(:new).with(uri_double.host, uri_double.port).and_return(connection_double)
        expect_any_instance_of(Hash).to receive(:set_form_data)
        expect(connection_double).to receive(:request).and_return('everything\'s chill')

        return_val = quote.post_request_for_new_customer
        expect(return_val).to eq('everything\'s chill')
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
  end
end