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

      it 'creates a Softwear Production order', create_production_order: true do
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

        expect(order.production.name).to eq order.name
        expect(job_1.production.name).to eq job_1.name
        expect(job_2.production.name).to eq job_2.name
        expect(imprint_1_1.production.name).to eq imprint_1_1.name
        expect(imprint_1_2.production.name).to eq imprint_1_2.name
        expect(imprint_2_1.production.name).to eq imprint_2_1.name
      end

      it 'adds imprintable trains to (only) jobs that have imprintable line items' do
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
    let!(:order) { create(:order, softwear_prod_id: prod_order.id) }

    it 'updates the name and deadline in production when changed' do
      order.name = "NEW order name"
      order.save!

      expect(prod_order.reload.name).to eq "NEW order name"
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
  end

  describe '#balance' do
    let(:order) { build_stubbed(:blank_order) }

    before do
      allow(order).to receive(:total).and_return(5)
      allow(order).to receive(:payment_total).and_return(5)
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
                    build_stubbed(:blank_payment, amount: 15, refunded: true)
                  ]
      )
    end

    it 'returns the total payment for the order' do
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
      allow(subject).to receive(:payment_total).and_return(5)
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

  describe '#generate_jobs', story_103: true do
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
            colors: [
              {
                color: color.id,
                sizes: [
                  {
                    size: size_s.id,
                    quantity: 10
                  },
                  {
                    size: size_m.id,
                    quantity: 11
                  },
                  {
                    size: size_l.id,
                    quantity: 12
                  },
                  nil,
                  {
                    size: size_xl.id,
                    quantity: 13
                  }
                ]
              }
            ]
          }
        ]
      end

      it 'creates jobs for each entry in the top level array', story_692: true do
        expect(order.jobs).to_not exist
        order.generate_jobs fba_params

        expect(order.jobs.where(name: 'test_fba FBA222EE2E')).to exist
        job = order.jobs.first

        variants.each do |variant|
          expect(job.line_items.where(imprintable_object_id: variant.id))
            .to exist
        end

        [10, 11, 12, 13].each do |quantity|
          expect(job.line_items.where(quantity: quantity)).to exist
        end
      end
    end
  end
end
