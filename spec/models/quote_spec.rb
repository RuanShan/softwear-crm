require 'spec_helper'

describe Quote, quote_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships', story_74: true, story_79: true do
    it { is_expected.to belong_to(:salesperson).class_name('User') }
    it { is_expected.to belong_to(:store) }
    it { is_expected.to have_many(:emails) }
    it { is_expected.to have_many(:jobs) }
    # it { is_expected.to have_and_belong_to_many(:quote_requests) }
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

      describe '#insightly_contact_links', story_610: true do
        context 'when the quote has quote requests' do
          let!(:quote_request_1) { create(:valid_quote_request_with_salesperson, insightly_contact_id: 123) }
          let!(:quote_request_2) do
            create(
              :valid_quote_request_with_salesperson,
              insightly_contact_id: 456,
              insightly_organisation_id: 789
            )
          end
          before { subject.quote_requests = [quote_request_1, quote_request_2] }

          it 'adds its contact and organisation ids' do
            expect(subject.insightly_contact_links).to eq [
              { contact_id: 123 },
              { contact_id: 456 },
              { organisation_id: 789 },
            ]
          end
        end

        context 'when the quote has no quote requests' do
          subject { create(:valid_quote, company: 'test company') }
          before { subject.update_attribute :company, 'test company' }

          it 'creates an insightly contact and organisation from its company' do
            dummy_insightly = Object.new
            expect(dummy_insightly).to receive(:get_contacts).and_return []
            expect(dummy_insightly).to receive(:get_organisations).and_return []
            expect(dummy_insightly).to receive(:create_organisation)
              .with(organisation: { organisation_name: 'test company' })
              .and_return(double('Organisation', organisation_id: 1))

            expect(dummy_insightly).to receive(:create_contact)
              .with(
                contact: {
                  first_name: subject.first_name,
                  last_name: subject.last_name,
                  contactinfos: [
                    { type: 'EMAIL', detail: subject.email },
                    { type: 'PHONE', detail: subject.phone_number }
                  ],
                  links: [{ organisation_id: 1 }]
                }
              )
              .and_return(
                double('Contact',
                  contact_id: 2,
                  links: [{ 'organisation_id' => 1 }]
                )
              )

            allow(subject).to receive(:insightly).and_return dummy_insightly

            expect(subject.insightly_contact_links).to eq [
              { contact_id: 2 },
              { organisation_id: 1 },
            ]
          end
        end
      end

      context 'when salesperson has an insightly api key' do
        before(:each) do
          allow(subject).to receive(:salesperson_has_insightly?).and_return true
          allow(subject).to receive(:create_insightly_opportunity)
        end

        (Quote::INSIGHTLY_FIELDS - [:insightly_opportunity_id]).each do |field|
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
            .and_return(double('Opportunity', opportunity_id: 123))

          allow(subject).to receive(:insightly).and_return dummy_insightly

          subject.create_insightly_opportunity
          expect(subject.reload.insightly_opportunity_id).to eq 123
        end

        context 'given an insightly_whos_responsible_id', story_670: true do
          let!(:responsible_user) { create(:alternate_user, email: 'testguy@annarbortees.com') }

          it 'adds their insightly user id to the create_opportunity call' do
            subject = create :valid_quote, insightly_whos_responsible_id: responsible_user.id
            dummy_insightly = Object.new
            subject.insightly_pipeline_id = 10
            allow(subject).to receive(:insightly_description).and_return 'desc'
            allow(subject).to receive(:insightly_bid_amount).and_return 15
            allow(subject).to receive(:insightly_stage_id).and_return 1
            allow(subject).to receive(:insightly_category_id).and_return 3

            expect(dummy_insightly).to receive(:get_users)
              .with("$filter" => "startswith(EMAIL_ADDRESS, 'testguy')")
              .and_return [double('insightly user', user_id: 559)]

            expect(dummy_insightly).to receive(:create_opportunity)
              .with(opportunity: hash_including(responsible_user_id: 559))
              .and_return(double('Opportunity', opportunity_id: 123))

            allow(subject).to receive(:insightly).and_return dummy_insightly

            subject.create_insightly_opportunity
          end
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

        context '#insightly_customfields', story_514: true, customfields: true do
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

          context 'when #deadline_is_specified? is true' do
            it 'adds OPPORTUNITY_FIELD_1 with estimated_delivery_date.strftime("%F %T")' do
              subject.estimated_delivery_date = 5.days.from_now
              subject.deadline_is_specified = true
              expect(customfields).to include(
                custom_field_id: 'OPPORTUNITY_FIELD_1',
                field_value: subject.estimated_delivery_date.strftime('%F %T')
              )
            end
          end

          context 'when #deadline_is_specified? is false' do
            it 'does not add OPPORTUNITY_FIELD_1' do
              subject.deadline_is_specified = false
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

    describe '#activity_updated_quote_fields_hash', story_600: true do
      let(:quote) { create(:valid_quote, first_name: 'Bob', is_rushed: false) }
      let(:success_hash) {
          {
            "first_name" => {
              "old" => "Bob",
              "new" => "Jim"
            },
            "is_rushed" => {
              "old" => false,
              "new" => true
            }
          }
        }
      context 'no change was made' do 
        it 'returns {}' do 
          expect(quote.activity_parameters_hash).to eq({})
        end
      end

      it 'analyzes the quote and returns a hash of fields that have changed', story: '600' do
        quote.first_name = 'Jim'
        quote.is_rushed = true        
        expect(quote.activity_parameters_hash).to eq(success_hash)
      end
    end

    describe '#activity_add_an_imprintable_hash', story_600: true do 
      let!(:quote) { create(:valid_quote) }

      context 'no change was made' do 
        it 'returns {}' do 
          expect(quote.activity_parameters_hash).to eq({})
        end
      end

      context 'two imprintables were added' do 
        let(:success_hash) {
        {
          :imprintables => {
          1 =>  {
              :imprintable_id => 1,
              :imprintable_price => 0.70, 
              :job_id => 1,
              :tier => 3,
              :quantity => 3,
              :decoration_price => 1.50
            },
          2 =>  {
              :imprintable_id => 2,
              :imprintable_price => 0.90, 
              :job_id => 1, 
              :tier => 1,
              :quantity => 3,
              :decoration_price => 1.33
            }
          }
        }
      }
    
      let!(:group) { create(:job, jobbable_id: quote.id, jobbable_type: 'Quote', name: 'A', description: 'b') }
      let(:iv1) { create(:valid_imprintable_variant) }
      let(:iv2) { create(:valid_imprintable_variant) }
      let(:iv3) { create(:valid_imprintable_variant) }
      let(:line_item_1) { create(:line_item, line_itemable_id: group.id, line_itemable_type: 'Job', imprintable_variant_id: iv1.id, imprintable_price: 0.70, decoration_price: 1.50, tier: 3) }
      let(:line_item_2) { create(:line_item, line_itemable_id: group.id, line_itemable_type: 'Job', imprintable_variant_id: iv2.id, imprintable_price: 0.90, decoration_price: 1.33, tier: 1) }
      
      it 'returns a hash with the imprintables added and the details about where they were added' do 
      #  quote.instance_variable_set("@imprintable_line_item_added_ids", [1,2])
        quote.instance_variable_set("@imprintable_line_item_added_ids", [line_item_1.id, line_item_2.id])
        expect(quote.activity_parameters_hash).to eq(success_hash)
      end
    end

    describe '#added_a_line_item_group_hash', story_600: true do
      context 'a job has been added' do
        let!(:quote) { create(:valid_quote) }
        let!(:line_item1) { create(:imprintable_line_item) }
        let!(:line_item2) { create(:imprintable_line_item) }
        let!(:imprint1) { create(:valid_imprint, description: "n\\a - Front") }
        let!(:imprint2) { create(:valid_imprint, description: "n\\a - Left Chest") }
        let!(:job) { create(:quote_job, line_items: [line_item1, line_item2], imprints: [imprint1, imprint2], jobbable: quote, name: "Test Job 1") }
        let(:success_hash) {
          {
            :imprintables => {
              line_item1.imprintable.id => line_item1.imprintable.base_price.to_f,
              line_item2.imprintable.id => line_item2.imprintable.base_price.to_f
            }, 
            :imprints => { #WIP only print_location_id so far
              imprint1.id =>   imprint1.description,
              imprint2.id => imprint2.description 
            },
            :name => job.name,
            :id => job.id, #group id aka job id
            :quantity => line_item1.quantity,
            :decoration_price => line_item1.decoration_price.to_f
          }
        }
        it 'returns a hash with information about imprintables, imprints, and other fields regarding the job' do
          quote.instance_variable_set("@group_added_id", job.id)          
          expect(quote.activity_parameters_hash).to eq(success_hash)
        end
      end
    end
    
    describe '#activity_parameters_for_job_changed', story_600xx: true do
        let!(:quote) { create(:valid_quote) }
        let!(:line_item1) { create(:imprintable_line_item) }
        let!(:line_item2) { create(:imprintable_line_item) }
        let!(:imprint1) { create(:valid_imprint) }
        let!(:imprint2) { create(:valid_imprint) }
        let!(:markup1)  { create(:non_imprintable_line_item) }
        let!(:markup2)  { create(:non_imprintable_line_item) }
        let!(:job) { create(:quote_job, line_items: [line_item1, line_item2], imprints: [imprint1, imprint2], jobbable: quote) }
        before do
          quote.markups_and_options_job.line_items += [markup1, markup2]
        end

        let(:success_hash) {
          {
            :group_id => job.id,  
            :name => { :old => job.name_was, :new => "Wumbo"},
            :description => { :old => job.description_was, :new => "Wumboism" },
            :line_items => {
                line_item1.id => {
                  :quantity => {:old => line_item1.quantity_was, :new => 40},
                  :decoration_price => {:old => line_item1.decoration_price_was.to_f, :new => 10.00},
                  :imprintable_price => {:old => line_item1.imprintable_price_was.to_f, :new => 18.00}
                },
                line_item2.id => {
                  :quantity => {:old => line_item2.quantity_was, :new => 30},
                  :decoration_price => {:old => line_item2.decoration_price_was.to_f, :new => 1.03},
                  :imprintable_price => {:old => line_item2.imprintable_price_was.to_f, :new => 8.00}
                }
              }, 
              :imprints => {
                imprint1.id => {
                  :old => {
                    :description => imprint1.description_was,
                    :print_location_id => imprint1.print_location_id_was
                  }, 
                  :new => {
                    :description => "14-orange",
                    :print_location_id => 2
                  }
                },
                imprint2.id => {
                  :old => {
                    :description => imprint2.description_was,
                    :print_location_id => imprint2.print_location_id_was
                  }, 
                  :new => {
                    :description => "3-red",
                    :print_location_id => 4
                  }
                }
              }
          }
        }

        let(:success_hash_markup) {
          {
            :group_id => job.id,  
            :name => { :old => job.name_was, :new => "Wumbo"},
            :description => { :old => job.description_was, :new => "Wumboism" },
            :line_items => {
                markup1.id => {
                  :unit_price => {:old => markup1.unit_price_was.to_f, :new => 40},
                },
                markup2.id => {
                  :unit_price => {:old => markup2.unit_price_was.to_f, :new => 10},
                }
              } 
          }
        }

        it 'returns a hash with all updated imprint and imprintable fields for the job' do
          # make changes to job 
          # then check for success hash
          l1o = LineItem.find(line_item1.id)
          l2o = LineItem.find(line_item2.id)
          i1o = Imprint.find(imprint1.id)
          i2o = Imprint.find(imprint2.id)

          li_old = [ l1o, l2o ]
          i_old = [ i1o, i2o ] 

          line_item1.quantity = 40
          line_item2.quantity = 30
          line_item1.decoration_price = 10
          line_item2.decoration_price = 1.03
          line_item2.imprintable_price = 8
          line_item1.imprintable_price = 18

          imprint1.description = "14-orange"
          imprint2.description = "3-red"
          imprint1.print_location_id = "2"
          imprint2.print_location_id = "4"
          
          job.name = "Wumbo"
          job.description = "Wumboism"

          expect(quote.activity_parameters_hash_for_job_changes(job, li_old, i_old)).to eq(success_hash)
        end

        it 'returns a hash with updated unit price for the markup/upcharge', story_692: true, pending: "Public Activity needs to be fixed by Ben" do
          markup1.unit_price = 40
          markup2.unit_price = 10
          l1o = LineItem.find(line_item1.id)
          l2o = LineItem.find(line_item2.id)
          i1o = Imprint.find(imprint1.id)
          i2o = Imprint.find(imprint2.id)
          li_old = [ l1o, l2o ]
          i_old = [ i1o, i2o ] 
          expect(quote.activity_parameters_hash_for_job_changes(job, li_old, i_old)).to eq(success_hash_markup)
        end
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

    describe '#create_freshdesk_ticket', story_518: true, freshdesk: true do
      before(:each) do
        allow(quote).to receive(:freshdesk_description)
          .and_return '<div>hi</div>'.html_safe

        allow(quote).to receive(:freshdesk_group_id).and_return 54321
        allow(quote).to receive(:freshdesk_department).and_return 'Testing'
      end

      context 'when the quote has a quote request' do
        it 'creates a ticket with its requester id' do
          dummy_quote_request = double('Quote Request', freshdesk_contact_id: 123)
          allow(quote).to receive(:quote_requests).and_return [dummy_quote_request]

          dummy_client = Object.new
          allow(quote).to receive(:freshdesk).and_return(dummy_client)

          expect(dummy_client).to receive(:post_tickets)
            .with(helpdesk_ticket: {
              source: 2,
              group_id: 54321,
              ticket_type: 'Lead',
              subject: "Your Quote \"#{quote.name}\" (##{quote.id}) from the Ann Arbor T-shirt Company",
              custom_field: {
                department_7483: 'Testing',
                softwearcrm_quote_id_7483: quote.id
              },
              description_html: anything,
              requester_id: 123
            })
            .and_return({ helpdesk_ticket: { display_id: 998 } }.to_json)

          quote.create_freshdesk_ticket
          expect(quote.freshdesk_ticket_id).to eq '998'
        end
      end

      context 'when the quote lacks a quote request' do
        it 'creates a ticket through its email, phone and full name', story_610: true do
          dummy_client = Object.new
          allow(quote).to receive(:freshdesk).and_return(dummy_client)

          expect(dummy_client).to receive(:post_tickets)
            .with(helpdesk_ticket: {
              source: 2,
              group_id: 54321,
              ticket_type: 'Lead',
              subject: anything,
              custom_field: {
                department_7483: 'Testing',
                softwearcrm_quote_id_7483: quote.id
              },
              description_html: anything,
              email: quote.email,
              phone: quote.phone_number,
              name: quote.full_name
            })
            .and_return({ helpdesk_ticket: { display_id: 2981 } }.to_json)

          quote.create_freshdesk_ticket
          expect(quote.freshdesk_ticket_id).to eq '2981'
        end
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

    context 'has 2 taxable and 2 non-taxable line items', wip: true do
      let!(:line_item) { create(:taxable_non_imprintable_line_item) }
      let!(:quote) { create(:valid_quote) }

      before(:each) do
        2.times { quote.markups_and_options_job.line_items << create(:taxable_non_imprintable_line_item) }
        expect(quote.line_items.size).to eq 2
      end

      describe '#line_items_subtotal', pending: 'Unsure what the deal is' do
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

      describe '#line_items_total_with_tax', pending: 'Unsure what the deal is' do
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

        it 'is empty' do
          expect(quote.standard_line_items).to be_empty
        end
      end

      context 'the quote has line items' do
        let!(:line_item) { create :non_imprintable_line_item }
        let!(:quote) { create(:valid_quote) }
        before { quote.markups_and_options_job.line_items << line_item }

        it 'returns the number of non-imprintable line items' do
          expect(quote.standard_line_items.size).to eq(1)
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
