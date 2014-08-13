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
    it { is_expected.to ensure_inclusion_of(:delivery_method).in_array Order::VALID_DELIVERY_METHODS }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to allow_value('test@example.com').for :email }
    it { is_expected.to_not allow_value('not_an-email').for :email }
    it { is_expected.to validate_presence_of :firstname }
    it { is_expected.to validate_presence_of :lastname }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to allow_value('123-654-9871').for :phone_number }
    it { is_expected.to_not allow_value('135184e6').for(:phone_number).with_message('is incorrectly formatted, use 000-000-0000') }
    it { is_expected.to validate_presence_of :salesperson }
    it { is_expected.to validate_presence_of :store }
    it { is_expected.to validate_presence_of :terms }

    let(:user) { create(:user) }
    it 'requires a tax id number if tax_exempt? is true' do
      expect(build_stubbed(:blank_order, store: build_stubbed(:blank_store), salesperson: user, tax_exempt: true)).to_not be_valid
    end
    it 'is valid when tax_exempt? is true and a tax id number is present' do
      expect(build_stubbed(:blank_order, store: build_stubbed(:blank_store), salesperson: user, tax_exempt: true, tax_id_number: 12)).to be_valid
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
      let!(:order) { (build_stubbed(:blank_order, terms: '')) }

      before(:each) do
        allow(order).to receive(:balance).and_return(10)
      end

      it 'returns Payment Terms Pending' do
        expect(order.payment_status).to eq('Payment Terms Pending')
      end
    end

    context 'balance <= 0' do
      let!(:order) { (build_stubbed(:blank_order, terms: 'Terms dont matter when payment is complete')) }

      before(:each) do
        allow(order).to receive(:balance).and_return(0)
      end

      it 'returns Payment Complete' do
        expect(order.payment_status).to eq('Payment Complete')
      end
    end

    context 'balance > 0' do
      before(:each) do
        allow(order).to receive(:balance).and_return(100)
      end

      context 'Terms: Paid in full on purchase' do
        let!(:order) { (build_stubbed(:blank_order, terms: 'Paid in full on purchase')) }

        context 'balance > 0' do
          it 'returns Awaiting Payment' do
            expect(order.payment_status).to eq('Awaiting Payment')
          end
        end
      end

      context 'Terms: Half down on purchase' do
        let!(:order) { (build_stubbed(:blank_order, terms: 'Half down on purchase')) }

        context 'balance greater than 49% of the total' do
          before(:each) do
            allow(order).to receive(:total).and_return(150)
          end

          it 'returns Awaiting Payment' do
            expect(order.payment_status).to eq('Awaiting Payment')
          end
        end
        context 'balance less than 49% of the total' do
          before(:each) do
            allow(order).to receive(:total).and_return(250)
          end

          it 'returns Payment Terms Met' do
            expect(order.payment_status).to eq('Payment Terms Met')
          end
        end
      end

      context 'Terms: Paid in full on pick up' do
        context 'Time.now greater than or equal to in_hand_by' do
          let!(:order) { (build_stubbed(:blank_order, terms: 'Paid in full on pick up', in_hand_by: Time.now - 1.day)) }

          it 'returns Awaiting Payment' do
            expect(order.payment_status).to eq('Awaiting Payment')
          end
        end
        context 'Time.now less than in_hand_by' do
          let!(:order) { (build_stubbed(:blank_order, terms: 'Paid in full on pick up', in_hand_by: Time.now + 1.day)) }

          it 'returns Payment Terms Met' do
            expect(order.payment_status).to eq('Payment Terms Met')
          end
        end
      end

      context 'Terms: Net 30' do
        context 'Time.now greater than or equal to in_hand_by + 30 days' do
          let!(:order) { (build_stubbed(:blank_order, terms: 'Paid in full on pick up', in_hand_by: Time.now - 55.day)) }

          it 'returns Awaiting Payment' do
            expect(order.payment_status).to eq('Awaiting Payment')
          end
        end
        context 'Time.now less than in_hand_by + 30 days' do
          let!(:order) { (build_stubbed(:blank_order, terms: 'Paid in full on pick up', in_hand_by: Time.now + 55.day)) }

          it 'returns Payment Terms Met' do
            expect(order.payment_status).to eq('Payment Terms Met')
          end
        end
      end

      context 'Terms: Net 60' do
        context 'Time.now greater than or equal to in_hand_by + 60 days' do
          let!(:order) { (build_stubbed(:blank_order, terms: 'Paid in full on pick up', in_hand_by: Time.now - 100.day)) }

          it 'returns Awaiting Payment' do
            expect(order.payment_status).to eq('Awaiting Payment')
          end
        end
        context 'Time.now less than in_hand_by + 60 days' do
          let!(:order) { (build_stubbed(:blank_order, terms: 'Paid in full on pick up', in_hand_by: Time.now + 100.day)) }

          it 'returns Payment Terms Met' do
            expect(order.payment_status).to eq('Payment Terms Met')
          end
        end
      end
    end
  end

  describe '#payment_total' do
    let(:order){ build_stubbed(:blank_order, payments: [build_stubbed(:blank_payment, amount: 5)]) }

    it 'returns the total payment for the order' do
      expect(order.total).to eq order.subtotal + order.subtotal * order.tax
    end
  end

  describe '#percent_paid' do
    let(:order){ build_stubbed(:blank_order) }
    before do
      allow(order).to receive(:total).and_return(5)
      allow(order).to receive(:payment_total).and_return(5)
    end

    it 'returns the percentage of the payment total over the order total' do
      expect(order.percent_paid).to eq((order.payment_total / order.total) * 100)
    end
  end

  describe '#subtotal' do
    let(:order){ build_stubbed(:blank_order) }
    before do
      allow(order).to receive(:line_items).and_return([build_stubbed(:blank_line_item, quantity: 5, unit_price: 5)])
    end

    it 'returns the sum of all the orders line item prices' do
      expect(order.subtotal.to_i).to eq(25)
    end
  end

  describe '#tax' do
    let(:order){ build_stubbed(:blank_order) }

    it 'returns the value for tax' do
      expect(order.tax).to eq(0.06)
    end
  end
end