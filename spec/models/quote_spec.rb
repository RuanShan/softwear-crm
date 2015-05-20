require 'spec_helper'

describe Quote, quote_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships', story_74: true, story_79: true do
    it { is_expected.to belong_to(:salesperson).class_name('User') }
    it { is_expected.to belong_to(:store) }
    it { is_expected.to have_many(:emails) }
    it { is_expected.to have_many(:jobs) }
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

    describe 'insightly', story_516: true, insightly: true do
      describe '#insightly_description', story_519: true do
        context 'when the quote is already linked with Freshdesk' do
          subject { build_stubbed :valid_quote, freshdesk_ticket_id: 123 }

          it 'appends a newline, and then a link to the Freshdesk ticket' do
            expect(subject).to receive(:freshdesk_ticket_link)
            subject.insightly_description
          end
        end

        context 'when the quote has no link with Freshdesk' do
          subject { build_stubbed :valid_quote, freshdesk_ticket_id: nil }

          it 'does not alter its standard description' do
            allow(subject).to receive(:description).and_return 'test'
            expect(subject.insightly_description).to eq 'test'
          end
        end
      end

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
          allow(subject).to receive(:insightly_description).and_return 'desc'
          allow(subject).to receive(:insightly_bid_amount).and_return 15
          allow(subject).to receive(:insightly_stage_id).and_return 1
          allow(subject).to receive(:insightly_category_id).and_return 3

          expect(dummy_insightly).to receive(:create_opportunity)
            .with({
              opportunity: {
                opportunity_name: subject.name,
                opportunity_state: 'Open',
                opportunity_details: 'desc',
                probability: subject.insightly_probability.to_i,
                bid_currency: 'USD',
                bid_amount: 15,
                forecast_close_date: (subject.created_at + 3.days).strftime('%F %T'),
                pipeline_id: 10,
                stage_id: 1,
                category_id: 3,
                customfields: subject.insightly_customfields,
                links: []
              }
            })
            .and_return(OpenStruct.new(opportunity_id: 123))

          allow(subject).to receive(:insightly).and_return dummy_insightly

          subject.create_insightly_opportunity
          expect(subject.reload.insightly_opportunity_id).to eq 123
        end

        context '#insightly_stage_id', story_603: true do
          subject { create :valid_quote, insightly_pipeline_id: 2 }
          let!(:dummy_insightly) { Object.new }

          it "returns the stage with an order of 1 and pipeline id matching the quote's" do
            expect(dummy_insightly).to receive(:get_pipeline_stages)
              .and_return([
                OpenStruct.new(stage_id: 1, pipeline_id: 1, stage_order: 1),
                OpenStruct.new(stage_id: 2, pipeline_id: 2, stage_order: 2),
                OpenStruct.new(stage_id: 3, pipeline_id: 2, stage_order: 1),
                OpenStruct.new(stage_id: 4, pipeline_id: 2, stage_order: 3),
              ])

            allow(subject).to receive(:insightly).and_return dummy_insightly

            expect(subject.insightly_stage_id).to eq 3
          end
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
            it 'adds OPPORTUNITY_FIELD_1 with estimated_delivery_date.strftime("%F %T")' do
              subject.estimated_delivery_date = 5.days.from_now
              subject.is_rushed = true
              expect(customfields).to include(
                custom_field_id: 'OPPORTUNITY_FIELD_1',
                field_value: subject.estimated_delivery_date.strftime('%F %T')
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
    let(:dummy_client) { Object.new }

    describe '#line_items_from_group_attributes=', story_567: true do
      subject { create(:valid_quote) }
      let!(:group) { ImprintableGroup.create(name: 'test group', description: 'yeah') }
      let!(:good_iv) { create(:valid_imprintable_variant) }
      let!(:better_iv) { create(:valid_imprintable_variant) }
      let!(:best_iv) { create(:valid_imprintable_variant) }
      let(:good) { good_iv.imprintable }
      let(:better) { better_iv.imprintable }
      let(:best) { best_iv.imprintable }

      let(:job) { subject.jobs.find_by(name: group.name) }

      before do
        allow(group).to receive(:default_imprintable_for_tier) { |tier|
          case tier
          when Imprintable::TIER.good then good
          when Imprintable::TIER.better then better
          when Imprintable::TIER.best then best
          end
        }
        allow(ImprintableGroup).to receive(:find)
          .with(group.id)
          .and_return group
      end

      let!(:attributes) do
        {
          imprintable_group_id: group.id,
          quantity: 2,
          decoration_price: 12.55,
        }
      end

      it 'generates a "good", "better", and "best" line item' do
        subject.line_items_from_group_attributes = attributes
        subject.save!

        expect(subject.jobs.where(name: group.name)).to exist
        expect(subject.jobs.where(description: group.description)).to exist

        expect(job.line_items.where(imprintable_variant_id: good_iv.id)).to exist
        expect(job.line_items.where(imprintable_variant_id: better_iv.id)).to exist
        expect(job.line_items.where(imprintable_variant_id: best_iv.id)).to exist

        good_li = job.line_items.where(imprintable_variant_id: good_iv.id).first
        better_li = job.line_items.where(imprintable_variant_id: better_iv.id).first
        best_li = job.line_items.where(imprintable_variant_id: best_iv.id).first

        expect(good_li.quantity).to eq 2
        expect(better_li.quantity).to eq 2
        expect(best_li.quantity).to eq 2

        expect(good_li.decoration_price).to eq 12.55
        expect(better_li.decoration_price).to eq 12.55
        expect(best_li.decoration_price).to eq 12.55

        expect(good_li.imprintable_price).to eq good.base_price
        expect(better_li.imprintable_price).to eq better.base_price
        expect(best_li.imprintable_price).to eq best.base_price

        expect(good_li.tier).to eq Imprintable::TIER.good
        expect(better_li.tier).to eq Imprintable::TIER.better
        expect(best_li.tier).to eq Imprintable::TIER.best
      end

      context 'when passed print_locations and imprint_descriptions as parralel arrays', story_570: true do
        let!(:print_location_1) { create(:print_location) }
        let!(:print_location_2) { create(:print_location) }

        let!(:attributes) do
          {
            imprintable_group_id: group.id,
            quantity: 2,
            decoration_price: 12.55,
            print_locations: [print_location_1.id.to_s, print_location_2.id.to_s],
            imprint_descriptions: ['Test desc for NUMERO UNO', 'Second test description']
          }
        end

        it 'generates imprints for the job with the given print location/descriptions' do
          subject.line_items_from_group_attributes = attributes
          subject.save!

          expect(job.imprints.size).to eq 2

          expect(job.imprints.first.print_location_id).to eq print_location_1.id
          expect(job.imprints.last.print_location_id).to eq print_location_2.id

          expect(job.imprints.first.description).to eq 'Test desc for NUMERO UNO'
          expect(job.imprints.last.description).to eq 'Second test description'
        end
      end

      context 'when there is no default imprintable for any tier' do
        before do
          allow(group).to receive(:default_imprintable_for_tier).and_return nil
        end

        it 'adds an error to the quote model' do
          subject.line_items_from_group_attributes = attributes
          expect(subject.save).to eq false
          expect(subject.errors[:line_items]).to include "Failed to find default imprintable for 'Good' tier"
        end
      end
    end

    describe '#line_item_to_group_attributes=', story_557: true do
      subject { create(:valid_quote, jobs: [create(:job)]) }
      let(:job) { subject.jobs.first }

      let!(:variant_1) { create(:valid_imprintable_variant) }
      let!(:variant_2) { create(:valid_imprintable_variant) }
      let!(:imprintable_1) { variant_1.imprintable }
      let!(:imprintable_2) { variant_2.imprintable }
      let!(:group) { ImprintableGroup.create(name: 'test group', description: 'yeah') }

      let!(:attributes) do
        {
          imprintables: [imprintable_1.id.to_s, imprintable_2.id.to_s],
          job_id: job.id,
          tier: Imprintable::TIER.better,
          quantity: 11,
          decoration_price: 15.30,
        }
      end

      it 'adds imprintable line items based on given imprintables' do
        subject.line_item_to_group_attributes = attributes
        subject.save!

        expect(job.line_items.size).to eq 2
        expect(job.line_items.where(imprintable_variant_id: variant_1.id)).to exist
        expect(job.line_items.where(imprintable_variant_id: variant_2.id)).to exist

        job.line_items.each do |line_item|
          expect(line_item.quantity).to eq 11
          expect(line_item.decoration_price).to eq 15.30
          expect(line_item.tier).to eq Imprintable::TIER.better
        end
        expect(job.line_items.where(imprintable_price: imprintable_1.base_price)).to exist
        expect(job.line_items.where(imprintable_price: imprintable_2.base_price)).to exist
      end
    end

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

    describe '#create_freshdesk_ticket', story_518: true do
      it 'calls Freshdesk.new and post_tickets with the correct args' do
        dummy_quote_request = double('Quote Request', freshdesk_contact_id: 123)
        allow(quote).to receive(:quote_requests).and_return [dummy_quote_request]
        allow(quote).to receive(:freshdesk_description)
          .and_return '<div>hi</div>'.html_safe

        allow(quote).to receive(:freshdesk_group_id).and_return 54321
        allow(quote).to receive(:freshdesk_department).and_return 'Testing'

        dummy_client = Object.new
        allow(quote).to receive(:freshdesk).and_return(dummy_client)

        allow(dummy_client).to receive(:post_tickets)
          .with(helpdesk_ticket: {
            requester_id: 123,
            requester_name: quote.full_name,
            source: 2,
            group_id: 54321,
            ticket_type: 'Lead',
            subject: "Your Quote (##{quote.name}) from the Ann Arbor T-shirt Company",
            custom_field: {
              department_7483: 'Testing',
              softwearcrm_quote_id_7483: quote.id
            },
            description_html: anything
          })
          .and_return({ helpdesk_ticket: { id: 998 } }.to_json)

        quote.create_freshdesk_ticket

        expect(quote.freshdesk_ticket_id).to eq 998
      end
    end

    describe '#fetch_freshdesk_ticket', story_518: true, fd_fetch: true, pending: 'unused! (for now)' do
      before(:each) do
        expect("UNUSED").to eq nil
      end

      context 'when there is a ticket with html matching the quote id' do
        let(:ticket_html) do
        end
        let(:dummy_ticket) do
          {
            display_id: 1233, email: 'crm@softwearcrm.com',
            description_html: %(
              <span id='softwear_quote_id' style='display: none;'>#{quote.id}</span>
              <div>it's me.</div>
            )
          }
        end

        before(:each) do
          allow(dummy_client).to receive(:get_tickets)
            .with(email: 'crm@softwearcrm.com', filter_name: 'all_tickets')
            .and_return [dummy_ticket].to_json

          allow(quote).to receive(:freshdesk).and_return dummy_client
        end

        it 'picks it up' do
          quote.fetch_freshdesk_ticket
          expect(quote.freshdesk_ticket_id).to eq 1233
        end
      end
    end

    describe '#set_freshdesk_ticket_requester', story_518: true, pending: 'unused! (for now)' do
      before(:each) do
        expect("UNUSED").to eq nil
      end

      context 'when the quote has a valid freshdesk ticket' do
        context 'and quote request with valid freshdesk contact' do
          let(:quote_request) do
            create :quote_request, freshdesk_contact_id: 2222
          end

          before(:each) do
            quote.quote_requests = [quote_request]
            quote.freshdesk_ticket_id = 1233
            quote.save!

            allow(quote).to receive(:freshdesk).and_return dummy_client
          end

          it "updates its ticket's requester with the first qr's info" do
            expect(dummy_client).to receive(:put_tickets)
              .with(
                id: 1233,
                helpdesk_ticket: {
                  requester_id: 2222,
                  source: 2,
                  group_id: anything,
                  ticket_type: 'Lead',
                  custom_field: {
                    softwearcrm_quote_id_7483: quote.id
                  }
                }
              )

            quote.set_freshdesk_ticket_requester
          end
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

    describe 'line item validation:' do
      context 'a quote without a line item' do
        it 'is invalid' do
          expect{
            create(:valid_quote)
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
        2.times { quote.default_job.line_items << create(:taxable_non_imprintable_line_item) }
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
