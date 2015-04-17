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

    describe 'insightly', story_516: true do
      context 'when salesperson has an insightly api key' do
        before(:each) do
          allow(subject).to receive(:salesperson_has_insightly?).and_return true
        end

        Quote::INSIGHTLY_FIELDS.each do |field|
          it { is_expected.to validate_presence_of(field) }
        end

        it 'can create an opportunity in Insightly', story_514: true do
          subject = create :valid_quote
          dummy_insightly = Object.new
          subject.insightly_pipeline_id = 10

          expect(dummy_insightly).to receive(:create_opportunity)
            .with({
              opportunity: {
                opportunity_name: subject.name,
                opportunity_state: 'Open',
                probability: subject.insightly_probability,
                bid_currency: 'USD',
                forecast_close_date: subject.valid_until_date.strftime('%F %T'),
                pipeline_id: 10,
                customfields: subject.insightly_customfields,
                links: []
              }
            })
            .and_return(OpenStruct.new(opportunity_id: 123))

          allow(subject).to receive(:insightly).and_return dummy_insightly

          subject.create_insightly_opportunity
          expect(subject.reload.insightly_opportunity_id).to eq 123
        end

        context '#insightly_customfields', story_514: true do
          subject { create :valid_quote }
          def customfields
            subject.insightly_customfields
          end

          context 'when there is an opportunity_profile_id' do
            it 'it adds OPPORTUNITY_FIELD_12 with its option value' do
              subject.insightly_opportunity_profile_id = 1
              allow(subject).to receive_message_chain(:insightly_opportunity_profile, :option_value)
                .and_return 'TARGET'
              expect(customfields).to include(
                custom_field_id: 'OPPORTUNITY_FIELD_12',
                field_value: 'TARGET'
              )
            end
          end

          context 'when there is a bid_tier_id' do
            it 'it adds OPPORTUNITY_FIELD_11 with its option value' do
              subject.insightly_bid_tier_id = 1
              allow(subject).to receive_message_chain(:insightly_bid_tier, :option_value)
                .and_return 'TARGET'
              expect(customfields).to include(
                custom_field_id: 'OPPORTUNITY_FIELD_11',
                field_value: 'TARGET'
              )
            end
          end

          it 'adds OPPORTUNITY_FIELD_3 with "Yes" or "No" depending on #deadline_is_specified?' do
            subject.deadline_is_specified = true
            expect(customfields).to include(
              custom_field_id: 'OPPORTUNITY_FIELD_3',
              field_value: 'Yes'
            )
            subject.deadline_is_specified = false
            expect(customfields).to include(
              custom_field_id: 'OPPORTUNITY_FIELD_3',
              field_value: 'No'
            )
          end

          it 'adds OPPORTUNITY_FIELD_5 with "Yes" or "No" depending on #is_rushed?' do
            subject.is_rushed = true
            expect(customfields).to include(
              custom_field_id: 'OPPORTUNITY_FIELD_5',
              field_value: 'Yes'
            )
            subject.is_rushed = false
            expect(customfields).to include(
              custom_field_id: 'OPPORTUNITY_FIELD_5',
              field_value: 'No'
            )
          end

          context 'when #is_rushed is true' do
            it 'adds OPPORTUNITY_FIELD_1 with valid_until_date.strftime("%F %T")' do
              subject.is_rushed = true
              expect(customfields).to include(
                custom_field_id: 'OPPORTUNITY_FIELD_1',
                field_value: subject.valid_until_date.strftime('%F %T')
              )
            end
          end
          context 'when #is_rushed is false' do
            it 'does not add OPPORTUNITY_FIELD_1' do
              subject.is_rushed = false
              expect(customfields.flat_map(&:values)).to_not include 'OPPORTUNITY_FIELD_1'
            end
          end

          it 'adds OPPORTUNITY_FIELD_2 with #qty' do
            subject.qty = 1234
            expect(customfields).to include(
              custom_field_id: 'OPPORTUNITY_FIELD_2',
              field_value: 1234
            )
          end

          it 'adds OPPORTUNITY_FIELD_10 with "Online - WordPress Quote Request"' do
            expect(customfields).to include(
              custom_field_id: 'OPPORTUNITY_FIELD_10',
              field_value: 'Online - WordPress Quote Request'
            )
          end
        end
      end

      context 'when salesperson does not have an insightly api key' do
        before(:each) do
          allow(subject).to receive(:salesperson_has_insightly?).and_return false
        end

        Quote::INSIGHTLY_FIELDS.each do |field|
          it { is_expected.to_not validate_presence_of(field) }
        end
      end
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

    describe '#get_freshdesk_ticket', story_70: true do
      # used for stubbing responses and methods
      class BogusClass; end
      # set expectations
      before(:each) do
        expect(FreshdeskModule).to receive(:get_freshdesk_config).and_return(
          {
            freshdesk_email: 'lolol',
            freshdesk_password: 'zomgwtfbbq'
          })
        expect(Freshdesk).to receive(:new).with(any_args).and_return(BogusClass)
        expect(BogusClass).to receive(:response_format=)
      end

      context 'when freshdesk returns a valid ticket' do
        # used to stub the "ticket"
        class SuccessClass; end
        it 'returns the ticket' do
          expect(BogusClass).to receive(:get_tickets).and_return('{ "success": "true"}')
          test = quote.get_freshdesk_ticket BogusClass
          expect(test.success).to eq('true')
        end
      end

      context 'when freshdesk returns an invalid ticket' do
        it 'returns an OpenStruct object with one field' do
          expect(BogusClass).to receive(:get_tickets).and_return nil
          test = quote.get_freshdesk_ticket BogusClass
          expect(test.quote_fd_id_configured).to eq('false')
        end
      end
    end

    describe '#no_ticket_id_entered?', story_70: true do
      context 'when a quote has a freshdesk_ticket_id' do
        let!(:quote) { build_stubbed(:valid_quote, freshdesk_ticket_id: '123456') }
        it 'returns false' do
          expect(quote.no_ticket_id_entered?).to be_falsey
        end
      end

      context 'when a quote does not have a freshdesk_ticket_id' do
        it 'returns true' do
          expect(quote.no_ticket_id_entered?).to be_truthy
        end
      end
    end

    describe '#no_fd_login?', story_70: true do
      # use this for stubbing out current_user in the method
      class BogusClass; end

      context 'when a user doesn\'t have any freshdesk configuration available' do
        it 'returns true' do
          expect(FreshdeskModule).to receive(:get_freshdesk_config).and_return({ lol: true })
          expect(quote.no_fd_login? BogusClass).to be_truthy
        end
      end

      context 'when a user has freshdesk configured' do
        it 'returns false' do
          expect(FreshdeskModule).to receive(:get_freshdesk_config).and_return(
          {
            freshdesk_email: 'something',
            freshdesk_password: 'something_else'
          })
          expect(quote.no_fd_login? BogusClass).to be_falsey
        end
      end
    end

    describe '#has_freshdesk_ticket?', story_70: true do
      # used for stubbing
      class BogusClass; end

      context 'when get_freshdesk_ticket returns a valid ticket' do
        it 'returns true' do
          expect(quote).to receive(:get_freshdesk_ticket).and_return(BogusClass)
          expect(BogusClass).to receive(:quote_fd_id_configured).and_return nil
          expect(quote.has_freshdesk_ticket? BogusClass).to be_truthy
        end
      end

      context 'when get_freshdesk_ticket returns an invalid ticket' do
        it 'returns false' do
          expect(quote).to receive(:get_freshdesk_ticket).and_return(BogusClass)
          expect(BogusClass).to receive(:quote_fd_id_configured).and_return true
          expect(quote.has_freshdesk_ticket? BogusClass).to be_falsey
        end
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
