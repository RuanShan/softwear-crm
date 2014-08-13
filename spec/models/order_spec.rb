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

    it { is_expected.to accept_nested_attributes_for :payments }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :delivery_method }
    it { is_expected.to ensure_inclusion_of(:delivery_method)
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

    let(:user) { create(:user) }
    it 'requires a tax id number if tax_exempt? is true' do
      order = build_stubbed(
        :blank_order,
        store:       build_stubbed(:blank_store),
        salesperson: user,
        tax_exempt:  true
      )
      expect(order).to_not be_valid
    end
    it 'is valid when tax_exempt? is true and a tax id number is present' do
      order = build_stubbed(
        :blank_order,
        store:         build_stubbed(:blank_store),
        salesperson:   user,
        tax_exempt:    true,
        tax_id_number: 12
      )
      expect(order).to be_valid
    end
  end

  describe '#balance' do
    let(:order){ build_stubbed(:blank_order) }

    before do
      allow(order).to receive(:total).and_return(5)
      allow(order).to receive(:payment_total).and_return(5)
    end

    it 'returns the order total minus the payment total' do
      expect(order.balance).to eq(order.total - order.payment_total)
    end
  end

  #TODO implement this
  describe 'get_salesperson_id'

  #TODO implement this
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
        payments: [build_stubbed(:blank_payment, amount: 5)]
      )
    end

    it 'returns the total payment for the order' do
      expect(subject.total)
        .to eq subject.subtotal + subject.subtotal * subject.tax
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

  describe '#tax' do
    subject do
      build_stubbed(:blank_order)
    end

    it 'returns the value for tax' do
      expect(subject.tax).to eq(0.06)
    end
  end
end