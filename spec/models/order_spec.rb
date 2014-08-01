require 'spec_helper'

describe Order, order_spec: true do
  describe 'Relationships' do
    it { should belong_to :store }
    it { should have_many :payments }
    it { should have_many :proof }
  end

  let!(:store) { create(:valid_store) }
  let!(:user) { create(:user) }

  context 'when validating' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :firstname }
    it { should validate_presence_of :lastname }
    it { should validate_presence_of :store }

    it { should validate_presence_of :name }
    it { should validate_presence_of :terms }
    it { should validate_presence_of :delivery_method }
    it { should validate_presence_of :salesperson_id }

    it { should allow_value('test@example.com').for :email }
    it { should_not allow_value('not_an-email').for :email }

    it { should allow_value('123-654-9871').for :phone_number }
    it { should_not allow_value('135184e6').for(:phone_number).with_message("is incorrectly formatted, use 000-000-0000") }

    it 'requires a tax id number if tax_exempt? is true' do
      expect(build(:order, store_id: store.id, store: store, salesperson_id: user.id, tax_exempt: true)).to_not be_valid
    end
    it 'is valid when tax_exempt? is true and a tax id number is present' do
      expect(build(:order, store_id: store.id, store: store, salesperson_id: user.id, tax_exempt: true, tax_id_number: 12)).to be_valid
    end

    it { should ensure_inclusion_of(:delivery_method).in_array Order::VALID_DELIVERY_METHODS }

  end

  context 'is non-deletable, and' do
    let!(:order) { create(:order) }

    it 'destroyed? returns false when not deleted' do
      expect(order.destroyed?).to eq false
    end
    it 'destroyed? returns true when deleted' do
      order.destroy
      expect(order.destroyed?).to eq true
    end

    it 'still exists after destroy is called' do
      order.destroy
      expect(Order.deleted).to include order
    end
    it 'is not accessible through the default scope once destroyed' do
      order.destroy
      expect(Order.all).to_not include order
    end

  end

  context 'relationships', line_item_spec: true do
    let!(:order) { create :order }

    context '#line_items' do
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

    it 'has a tax constant that returns 0.6 for now' do
      expect(order.tax).to eq 0.6
    end

    it 'has a subtotal that returns the sum of all its line item prices' do
      expect { order.subtotal }.to_not raise_error
      sum = 0
      order.line_items.each do |line_item|
        sum += line_item.total_price
      end
      expect(order.subtotal).to eq sum
    end

    it 'has a total that returns the subtotal plus tax' do
      expect { order.total }.to_not raise_error
      expect(order.total).to eq order.subtotal + order.subtotal * order.tax
    end

    context '#salesperson_name' do
      it 'returns the salesperson\'s name associated with the order' do
        salesperson = User.find(order.salesperson_id)
        expect(salesperson.full_name).to eq(order.salesperson_name)
      end
    end

    context '#'
  end

  before(:each) do
    @order = FactoryGirl.create(:order)
    @payment = FactoryGirl.create(:valid_payment)
    @payment.order = @order
    @payment.save
  end

  describe '#payment_total' do
    context 'there are a total of five payments of ten dollars each' do
      it 'returns 50 dollars' do
        4.times {
          payment = FactoryGirl.create(:valid_payment)
          payment.order = @order
          payment.save
        }

        expect(@order.payment_total).to eq(50)
      end
    end
  end

  describe '#balance' do
    it 'returns the order total minus the payment total' do
      expect(@order.balance).to eq(@order.total - @payment.amount)
    end
  end

  describe '#percent_paid' do

    it 'returns the percentage of the payment total over the order total' do
      expect(@order.percent_paid).to eq((@payment.amount / @order.total)*100)
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
end
