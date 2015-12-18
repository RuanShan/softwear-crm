require 'spec_helper'

describe Order, order_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to :salesperson }
    it { is_expected.to belong_to :store }
    it { is_expected.to have_many :artwork_requests }
    it { is_expected.to have_many :jobs }
    it { is_expected.to have_many :payments }
    it { is_expected.to have_many :proofs }
    it { is_expected.to have_many(:imprints).through(:jobs) }
    it { is_expected.to have_many(:quotes) }

    it { is_expected.to accept_nested_attributes_for :payments }
    # TODO: not sure if this should be gone?
    # it { is_expected.to accept_nested_attributes_for :jobs }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :invoice_state }
    it { is_expected.to validate_inclusion_of(:invoice_state)
           .in_array Order::VALID_INVOICE_STATES }
    it { is_expected.to validate_presence_of :production_state }
    it { is_expected.to validate_inclusion_of(:production_state)
           .in_array Order::VALID_PRODUCTION_STATES }
    it { is_expected.to validate_presence_of :delivery_method }
    it { is_expected.to validate_inclusion_of(:delivery_method)
           .in_array Order::VALID_DELIVERY_METHODS }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to allow_value('test@example.com').for :email }
    it { is_expected.to_not allow_value('not_an-email').for :email }
    it { is_expected.to validate_presence_of :firstname }
    it { is_expected.to validate_presence_of :lastname }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to allow_value('123-654-9871').for :phone_number }
    it { is_expected.to_not allow_value('135184e6').for(:phone_number)
           .with_message('is incorrectly formatted, use 000-000-0000') }
    it { is_expected.to validate_presence_of :salesperson }
    it { is_expected.to validate_presence_of :store }
    it { is_expected.to validate_presence_of :terms }
    it { is_expected.to validate_presence_of :in_hand_by }

    let!(:store) { create(:valid_store) }
    let!(:user) { create(:user) }
  end

  describe 'Scopes' do
    describe 'fba', story_103: true do
      let!(:fba_order) { create :order, terms: 'Fulfilled by Amazon' }
      let!(:normal_order) { create :order }

      it 'retrieves only fba orders' do
        expect(Order.fba).to include fba_order
        expect(Order.fba).to_not include normal_order
      end
    end
  end

  describe '#create_production_order' do
    describe 'when payment_status reaches "Payment Terms Met" and invoice_status reaches "approved"', story_96: true do
      let!(:order) { create(:order) }

      let!(:job_1) { create(:job, jobbable: order) }
      let!(:imprint_1_1) { create(:valid_imprint, job: job_1) }
      let!(:imprint_1_2) { create(:valid_imprint, job: job_1) }

      let!(:job_2) { create(:job, jobbable: order) }
      let!(:imprint_2_1) { create(:valid_imprint, job: job_2) }

      before do
        allow_any_instance_of(Order).to receive(:enqueue_create_production_order, &:create_production_order)
        allow_any_instance_of(Job).to receive(:create_trains_from_artwork_request)
      end

      it 'creates a Softwear Production order', create_production_order: true, pending: 'Todo for nigel' do
        [order, job_1, job_2, imprint_1_1, imprint_1_2, imprint_2_1].each do |record|
          expect(record.reload.softwear_prod_id).to be_nil
        end

        allow(order).to receive(:payment_status).and_return 'Payment Terms Met'
        order.invoice_state = 'approved'
        order.save!

        %w(order job_1 job_2 imprint_1_1 imprint_1_2 imprint_2_1).each do |record|
          expect(eval(record).reload.softwear_prod_id).to_not be_nil,
            "#{record} was not assigned a softwear_prod_id"
        end

        expect(Production::Order.where(softwear_crm_id: order.id)).to be_any
        expect(Production::Job.where(softwear_crm_id: job_1.id)).to be_any
        expect(Production::Job.where(softwear_crm_id: job_2.id)).to be_any
        expect(Production::Imprint.where(softwear_crm_id: imprint_1_1.id)).to be_any
        expect(Production::Imprint.where(softwear_crm_id: imprint_1_2.id)).to be_any
        expect(Production::Imprint.where(softwear_crm_id: imprint_2_1.id)).to be_any

        expect(order.production.name).to eq order.name_in_production
        expect(job_1.production.name).to eq job_1.name
        expect(job_2.production.name).to eq job_2.name
        expect(imprint_1_1.production.name).to eq imprint_1_1.name
        expect(imprint_1_2.production.name).to eq imprint_1_2.name
        expect(imprint_2_1.production.name).to eq imprint_2_1.name
      end

      it 'adds imprintable trains to (only) jobs that have imprintable line items', pending: 'todo for nigel' do
        job_1.line_items << create(:imprintable_line_item)

        allow(order).to receive(:payment_status).and_return 'Payment Terms Met'
        order.invoice_state = 'approved'

        order.save!

        expect(job_1.reload.production.imprintable_train.state).to eq 'ready_to_order'
        expect(job_2.reload.production.imprintable_train).to be_nil
      end
    end
  end

  describe 'with a production order', story_932: true do
    let!(:prod_order) { create(:production_order) }
    let!(:order) { create(:order, softwear_prod_id: prod_order.id, firstname: 'first', lastname: 'last') }

    it 'updates the name and deadline in production when changed' do
      order.name = "NEW order name"
      order.save!

      expect(prod_order.reload.name).to eq "first last - NEW order name"
    end

    specify '#create_production_order(force: false) fails', story_961: true do
      expect{order.create_production_order force: false}.to raise_error
    end
  end

  describe 'upon initialization' do
    subject { create(:order) }

    it 'sets invoice_state to pending' do
      expect(subject.invoice_state).to eq('pending')
    end

    it 'sets production_state to pending' do
      expect(subject.production_state).to eq('pending')
    end

    it 'generates a customer key' do
      expect(subject.customer_key.blank?).to_not be_truthy
    end
  end

  describe '#balance' do
    let(:order) { build_stubbed(:blank_order) }

    before do
      allow(order).to receive(:total).and_return(5)
      allow(order).to receive(:payment_total_excluding).with([]).and_return(5)
    end

    it 'returns the order total minus the payment total' do
      expect(order.balance).to eq(order.total - order.payment_total)
    end
  end

  # TODO implement this
  describe 'get_salesperson_id'

  # TODO implement this
  describe 'get_store_id'

  describe '#line_items' do
    let!(:order) { create :order }

    it 'is an ActiveRecord::Relation' do
      expect { order.line_items }.to_not raise_error
      expect(order.line_items).to be_a ActiveRecord::Relation
    end

    it 'actually works' do
      job1 = create(:job)
      job2 = create(:job)
      [job1, job2].each do |job|
        2.times { job.line_items << create(:non_imprintable_line_item) }
        order.jobs << job
      end

      expect(order.line_items.count).to eq 4
      expect(order.line_items).to include job1.line_items.first
      expect(order.line_items).to include job2.line_items.first
    end
  end

  describe '#payment_status' do
    context 'terms are empty' do
      subject { (build_stubbed(:blank_order, terms: '')) }

      before(:each) do
        allow(subject).to receive(:balance).and_return(10)
      end

      it 'returns Payment Terms Pending' do
        expect(subject.payment_status).to eq('Payment Terms Pending')
      end
    end

    context 'balance <= 0' do
      subject do
        build_stubbed(
          :blank_order,
          terms: 'Terms dont matter when payment is complete'
        )
      end

      before(:each) do
        allow(subject).to receive(:balance).and_return(0)
      end

      it 'returns Payment Complete' do
        expect(subject.payment_status).to eq('Payment Complete')
      end
    end

    context 'balance > 0' do
      before(:each) do
        allow(subject).to receive(:balance).and_return(100)
      end

      context 'Terms: Paid in full on purchase' do
        subject do
          build_stubbed(:blank_order, terms: 'Paid in full on purchase')
        end

        context 'balance > 0' do
          it 'returns Awaiting Payment' do
            expect(subject.payment_status).to eq('Awaiting Payment')
          end
        end
      end

      context 'Terms: Half down on purchase' do
        subject do
          build_stubbed(:blank_order, terms: 'Half down on purchase')
        end

        context 'balance greater than 49% of the total' do
          before(:each) do
            allow(subject).to receive(:total).and_return(150)
          end

          it 'returns Awaiting Payment' do
            expect(subject.payment_status).to eq('Awaiting Payment')
          end
        end
        context 'balance less than 49% of the total' do
          before(:each) do
            allow(subject).to receive(:total).and_return(250)
          end

          it 'returns Payment Terms Met' do
            expect(subject.payment_status).to eq('Payment Terms Met')
          end
        end
      end

      context 'Terms: Paid in full on pick up' do
        context 'Time.now greater than or equal to in_hand_by' do
          subject do
            build_stubbed(
              :blank_order,
              terms:      'Paid in full on pick up',
              in_hand_by: Time.now - 1.day
            )
          end

          it 'returns Awaiting Payment' do
            expect(subject.payment_status).to eq('Awaiting Payment')
          end
        end
        context 'Time.now less than in_hand_by' do
          subject do
            build_stubbed(
              :blank_order,
              terms:      'Paid in full on pick up',
              in_hand_by: Time.now + 1.day
            )
          end

          it 'returns Payment Terms Met' do
            expect(subject.payment_status).to eq('Payment Terms Met')
          end
        end
      end

      context 'Terms: Net 30' do
        context 'Time.now greater than or equal to in_hand_by + 30 days' do
          subject do
            build_stubbed(
              :blank_order,
              terms:      'Paid in full on pick up',
              in_hand_by: Time.now - 55.day
            )
          end

          it 'returns Awaiting Payment' do
            expect(subject.payment_status).to eq('Awaiting Payment')
          end
        end
        context 'Time.now less than in_hand_by + 30 days' do
          subject do
            build_stubbed(
              :blank_order,
              terms:      'Paid in full on pick up',
              in_hand_by: Time.now + 55.day
            )
          end

          it 'returns Payment Terms Met' do
            expect(subject.payment_status).to eq('Payment Terms Met')
          end
        end
      end

      context 'Terms: Net 60' do
        context 'Time.now greater than or equal to in_hand_by + 60 days' do
          subject do
            build_stubbed(
              :blank_order,
              terms:      'Paid in full on pick up',
              in_hand_by: Time.now - 100.days
            )
          end

          it 'returns Awaiting Payment' do
            expect(subject.payment_status).to eq('Awaiting Payment')
          end
        end
        context 'Time.now less than in_hand_by + 60 days' do
          subject do
            build_stubbed(
              :blank_order,
              terms:      'Paid in full on pick up',
              in_hand_by: Time.now + 100.day
            )
          end

          it 'returns Payment Terms Met' do
            expect(subject.payment_status).to eq('Payment Terms Met')
          end
        end
      end
    end
  end

  describe '#payment_total' do
    subject do
      build_stubbed(
        :blank_order,
        payments: [
                    build_stubbed(:blank_payment, amount: 5),
                    build_stubbed(:blank_payment, amount: 10),
                    build_stubbed(:blank_payment, amount: 15)
                  ]
      )
    end

    it 'returns the total payment for the order' do
      allow(subject.payments.last).to receive(:totally_refunded?).and_return true
      expect(subject.payment_total)
        .to eq 15
    end
  end

  describe '#percent_paid' do
    subject do
      build_stubbed(:blank_order)
    end
    before do
      allow(subject).to receive(:total).and_return(5)
      allow(subject).to receive(:payment_total_excluding).and_return(5)
    end

    it 'returns the percentage of the payment total over the order total' do
      expect(subject.percent_paid)
        .to eq((subject.payment_total / subject.total) * 100)
    end
  end

  describe '#subtotal' do
    subject do
      build_stubbed(:blank_order)
    end
    before do
      allow(subject).to receive(:line_items)
        .and_return(
          [build_stubbed(:blank_line_item, quantity: 5, unit_price: 5)]
        )
    end

    it 'returns the sum of all the orders line item prices' do
      expect(subject.subtotal.to_i).to eq(25)
    end
  end

  describe '#missing_proofs?', pending: true do
    let(:proof) { create(:proof) }
    let(:artwork_request) { build_stubbed(:artwork_request) }
    let(:order) { create(:order) }
    before do
      order.proofs << proof
    end

    context 'all artwork requests have at least one proof associated with them' do
      before do
        allow(order).to receive(:artwork_requests) { [artwork_request] }
        allow(artwork_request).to receive(:proofs) { Proof.where(id: proof.id) }
      end

      it 'returns false' do
        expect(order.missing_proofs?).to be_falsy
      end

    end

    context 'at least one artwork request has no proof associated with it' do
      let(:artwork_request_2) { build_stubbed(:artwork_request) }

      before do
        allow(order).to receive(:artwork_requests) { [artwork_request, artwork_request_2] }
        allow(artwork_request).to receive(:proofs) { Proof.where(id: proof.id) }
      end

      it 'returns true' do
        expect(order.missing_proofs?).to be_truthy
      end
    end
  end

  describe '#missing_approved_proofs?' do

    let(:artwork_request) { build_stubbed(:artwork_request) }
    let(:order) { create(:order) }

    context 'all artwork requests have at least one approved proof with them' do
      before do
        allow(order).to receive(:artwork_requests) { [artwork_request] }
        allow(artwork_request).to receive(:has_approved_proof?) { true }
      end

      it 'returns false' do
        expect(order.missing_approved_proofs?).to be_falsy
      end

    end

    context 'at least one artwork request has no proof associated with it' do
      before do
        allow(order).to receive(:artwork_requests) { [artwork_request] }
        allow(artwork_request).to receive(:has_approved_proof?) { false }
      end

      it 'returns true' do
        expect(order.missing_approved_proofs?).to be_truthy
      end
    end
  end

  describe '#generate_jobs', story_957: true, story_103: true do
    let!(:order) { create :order }

    context 'given a hash of imprintables, colors, and sizes' do
      let!(:size_s) { create :valid_size, sku: '02' }
      let!(:size_m) { create :valid_size, sku: '03' }
      let!(:size_l) { create :valid_size, sku: '04' }
      let!(:size_xl) { create :valid_size, sku: '05' }
      let!(:color) { create :valid_color, sku: '000' }
      let!(:imprintable) { create :valid_imprintable, sku: '0705' }
      let!(:variants) do
        [size_s, size_m, size_l, size_xl].map do |size|
          create(
            :blank_imprintable_variant,
            imprintable_id: imprintable.id,
            color_id: color.id,
            size_id: size.id
          )
        end
      end

      let(:fba_params) do
        [
          {
            job_name: 'test_fba FBA222EE2E',
            imprintable: imprintable.id,
            imprintables: [
              [
                imprintable.id,
                color.id,
                {
                  size_s.id.to_s  => 10,
                  size_m.id.to_s  => 11,
                  size_l.id.to_s  => 12,
                  size_xl.id.to_s => 13
                }
              ]
            ]
          }
        ]
      end

      it 'creates jobs for each entry in the top level array', story_692: true, pending: 'todo for nigel' do
        expect(order.jobs).to_not exist
        order.generate_jobs fba_params

        expect(order.jobs.where(name: 'test_fba FBA222EE2E')).to exist
        job = order.jobs.first

        variants.each do |variant|
          expect(job.line_items.where(imprintable_object_id: variant.id))
            .to exist
        end

        expect(job.line_items.where(quantity: 10)).to exist
        expect(job.line_items.where(quantity: 11)).to exist
        expect(job.line_items.where(quantity: 12)).to exist
        expect(job.line_items.where(quantity: 13)).to exist
      end
    end
  end

  describe "#screen_print_artwork_requests"  do
    context 'order has artwork request with Screen Print or Large Format Screen Print imprints', ar_order: true do
      let(:artwork_request) { create(:valid_artwork_request) }
      let(:order) { artwork_request.order }
      before(:each) { allow_any_instance_of(ArtworkRequest).to receive(:imprint_method) {build_stubbed(:screen_print_imprint_method) } }

      it 'returns an array of those requests' do
        expect(order.screen_print_artwork_requests).to eq([artwork_request])
      end
    end
  end

  describe "#embroidery_artwork_requests" do
    context "order has artwork request with 'In-House Embroidery', 'Outsourced Embroidery' or 'In-House Applique EMB' imprints" do
      let(:artwork_request) { create(:valid_artwork_request) }
      let(:order) { artwork_request.order }
      before(:each) { allow_any_instance_of(ArtworkRequest).to receive(:imprint_method) {build_stubbed(:embroidery_imprint_method) } }

      it 'returns an array of those requests' do
        expect(order.embroidery_artwork_requests).to eq([artwork_request])
      end
    end
  end

  describe "#dtg_artwork_requests"  do
    context "order has artwork request with 'Digital Print - Non-White (DTG-NW)' or 'Digital Print - White (DTG-W)' imprints" do
      let(:artwork_request) { create(:valid_artwork_request) }
      let(:order) { artwork_request.order }
      before(:each) { allow_any_instance_of(ArtworkRequest).to receive(:imprint_method) {build_stubbed(:dtg_imprint_method) } }

      it 'returns an array of those requests' do
        expect(order.dtg_artwork_requests).to eq([artwork_request])
      end
    end
  end

  describe '#invoice_should_be_approved_by_now?' do
    context 'in_hand_by is less than or equal to 6 business days from now' do
      let(:order) { create(:order, in_hand_by: 5.business_days.from_now) }

      it 'returns true' do
        expect(order.invoice_should_be_approved_by_now?).to eq(true)
      end
    end

    context 'in_hand_by is greater than 6 business days from now' do
      let(:order) { create(:order, in_hand_by: 7.business_days.from_now) }

      it 'returns true' do
        expect(order.invoice_should_be_approved_by_now?).to eq(false)
      end
    end
  end

  describe '#prod_api_confirm_job_counts' do
    context "production order doesn't have the same amount of jobs" do

      let!(:prod_order) { create(:production_order) }
      let!(:order) { create(:order_with_job, softwear_prod_id: prod_order.id) }

      it 'creates a warning' do
        expect {
          order.prod_api_confirm_job_counts
        }.to change{order.warnings_count}.from(0).to(1)
      end
    end

    context "production order has the same amount of jobs" do

      let!(:prod_order) { create(:production_order_with_job) }
      let!(:order) { create(:order_with_job, softwear_prod_id: prod_order.id) }

      it 'does nothing' do
        expect {
          order.prod_api_confirm_job_counts
        }.not_to change{order.warnings_count}
      end
    end
  end

  describe '#prod_api_confirm_artwork_preprod' do
    context "order has artwork requests with Screen Prints or Large Format Screen Prints" do

      let!(:prod_order) { create(:production_order) }
      let!(:order) { create(:order_with_job, softwear_prod_id: prod_order.id) }

      context "and doesn't have the same amount of screen_trains as these ArtworkRequests" do
        let!(:prod_order) { create(:production_order, pre_production_trains: [] ) }

        before(:each) { allow_any_instance_of(Order).to receive(:screen_print_artwork_requests) {[1]} }

        it 'it creates a warning' do
          expect {
            order.prod_api_confirm_artwork_preprod
          }.to change{order.warnings_count}.from(0).to(1)
        end
      end

      context "and has the same amount of screen_trains as these ArtworkRequests" do
        let!(:screen_train) { {train_class: 'screen_train'} }
        let!(:prod_order) { create(:production_order, pre_production_trains: [screen_train] ) }

        before(:each) { allow_any_instance_of(Order).to receive(:screen_print_artwork_requests) {[1]} }

        it 'it does nothing' do
          expect {
            order.prod_api_confirm_artwork_preprod
          }.not_to change{order.warnings_count}
        end
      end

    end

    context "order has artwork requests with Embroidery Prints" do

      let!(:prod_order) { create(:production_order) }
      let!(:order) { create(:order_with_job, softwear_prod_id: prod_order.id) }

      context "and doesn't have the same amount of digitization_trains as these ArtworkRequests" do
        let!(:prod_order) { create(:production_order, pre_production_trains: [] ) }

        before(:each) { allow_any_instance_of(Order).to receive(:embroidery_artwork_requests) {[1]} }

        it 'it creates a warning' do
          expect {
            order.prod_api_confirm_artwork_preprod
          }.to change{order.warnings_count}.from(0).to(1)
        end
      end

      context "and has the same amount of digitization_trains as these ArtworkRequests" do
        let!(:digitization_train) { {train_class: 'digitization_train'} }
        let!(:prod_order) { create(:production_order, pre_production_trains: [digitization_train] ) }

        before(:each) { allow_any_instance_of(Order).to receive(:embroidery_artwork_requests) {[1]} }

        it 'it does nothing' do
          expect {
            order.prod_api_confirm_artwork_preprod
          }.not_to change{order.warnings_count}
        end
      end

    end

    context "order has artwork requests with DTG Prints" do

      let!(:prod_order) { create(:production_order) }
      let!(:order) { create(:order_with_job, softwear_prod_id: prod_order.id) }

      context "and doesn't have the same amount of ar3_trains as these ArtworkRequests" do
        let!(:prod_order) { create(:production_order, pre_production_trains: [] ) }

        before(:each) { allow_any_instance_of(Order).to receive(:dtg_artwork_requests) {[1]} }

        it 'it creates a warning' do
          expect {
            order.prod_api_confirm_artwork_preprod
          }.to change{order.warnings_count}.from(0).to(1)
        end
      end

      context "and has the same amount of ar3_trains as these ArtworkRequests" do
        let!(:ar3_train) { {train_class: 'ar3_train'} }
        let!(:prod_order) { create(:production_order, pre_production_trains: [ar3_train] ) }

        before(:each) { allow_any_instance_of(Order).to receive(:dtg_artwork_requests) {[1]} }

        it 'it does nothing' do
          expect {
            order.prod_api_confirm_artwork_preprod
          }.not_to change{order.warnings_count}
        end
      end

    end
  end

  describe '#prod_api_confirm_shipment' do
    context "delivery_method is 'Pick up in Ann Arbor'" do

      let!(:order) { create(:order_with_job, delivery_method: "Pick up in Ann Arbor", softwear_prod_id: prod_order.id) }

      context "and production order doesn't have a StageForPickupTrain" do
      let!(:prod_order) { create(:production_order_with_post_production_trains) }
        it 'creates a warning' do
          expect {
            order.prod_api_confirm_shipment
          }.to change{order.warnings_count}.from(0).to(1)
        end
      end

      context "and production order has a StageForPickupTrain" do
        let(:stage_for_pickup_train) { {train_class: 'stage_for_pickup_train'} }
        let!(:prod_order) { create(:production_order, post_production_trains: [ stage_for_pickup_train ]) }

        it 'creates a warning' do
          expect {
            order.prod_api_confirm_shipment
          }.to_not change{order.warnings_count}
        end
      end
    end

    context "delivery_method is 'Pick up in Ypsilanti'" do

      let!(:order) { create(:order_with_job, delivery_method: "Pick up in Ypsilanti", softwear_prod_id: prod_order.id) }

      context "and production order doesn't have a StoreDeliveryTrain" do
        let!(:prod_order) { create(:production_order_with_post_production_trains) }

        it 'creates a warning' do
          expect {
            order.prod_api_confirm_shipment
          }.to change{order.warnings_count}.from(0).to(1)
        end
      end

      context "and production order has a StageForPickupTrain" do
        let(:store_delivery_train) { {train_class: 'store_delivery_train'} }
        let!(:prod_order) { create(:production_order, post_production_trains: [ store_delivery_train ]) }

        it 'creates a warning' do
          expect {
            order.prod_api_confirm_shipment
          }.to_not change{order.warnings_count}
        end
      end
    end

    context "delivery_method is 'Ship to one location'" do
      let!(:order) { create(:order_with_job, delivery_method: "Ship to one location") }

      context 'and shipments are empty' do

        it 'creates a warning' do
          expect {
            order.prod_api_confirm_shipment
          }.to change{order.warnings.count}.from(0).to(1)
        end
      end

      context "there are shipments, and that shipment is an 'Ann Arbor Tees Delivery'" do
        let!(:shipment) { create(:ann_arbor_tees_delivery_shipment) }
        let!(:order) { create(:order_with_job, delivery_method: "Ship to one location", softwear_prod_id: prod_order.id, shipments: [shipment]) }

        context 'and production order has a LocalDeliveryTrain' do
          let(:local_delivery_train) { {train_class: 'local_delivery_train'} }
          let!(:prod_order) { create(:production_order, post_production_trains: [ local_delivery_train ]) }

          it 'does nothing' do
            expect {
              order.prod_api_confirm_shipment
            }.not_to change{order.warnings_count}
          end
        end

        context 'and production order does not have a LocalDeliveryTrain' do
          let!(:prod_order) { create(:production_order, post_production_trains: []) }

          it 'creates a warning' do
            expect {
              order.prod_api_confirm_shipment
            }.to change{order.warnings_count}.from(0).to(1)
          end
        end
      end

      context "there are shipments, and that shipment is anything but an 'Ann Arbor Tees Delivery'" do
        let!(:shipment) { create(:shipment) }
        let!(:order) { create(:order_with_job, delivery_method: "Ship to one location", softwear_prod_id: prod_order.id, shipments: [shipment]) }

        context 'and production order has a ShipmentTrain' do
          let(:shipment_train) { {train_class: 'shipment_train'} }
          let!(:prod_order) { create(:production_order, post_production_trains: [ shipment_train ]) }

          it 'does nothing' do
            expect {
              order.prod_api_confirm_shipment
            }.not_to change{order.warnings_count}
          end
        end

        context 'and production order does not have a ShpmentTrain' do
          let!(:prod_order) { create(:production_order, post_production_trains: []) }

          it 'creates a warning' do
            expect {
              order.prod_api_confirm_shipment
            }.to change{order.warnings_count}.from(0).to(1)
          end
        end
      end
    end

    context "delivery_method is 'Ship to multiple locations'" do
      let!(:order) { create(:order_with_job, delivery_method: "Ship to multiple locations") }

      it 'creates a warning' do
        expect {
          order.prod_api_confirm_shipment
        }.to change{order.warnings_count}.from(0).to(1)
      end
    end
  end

end
