require 'spec_helper'

describe Coupon do
  let(:order) { create(:order_with_job) }

  describe 'Calculators', story_857: true do
    describe '#percent_off_order' do
      subject { create :percent_off_order, value: 10.0 }
      before do
        allow(order).to receive(:line_items).and_return [double('LineItem', total_price: 12.5)] * 3
      end

      it "reduces the order's subtotal by #value %" do
        expect(order.subtotal).to eq 12.5*3

        subject.apply(order, nil)

        expect(order.subtotal).to eq (12.5*3) - (12.5*3)*0.10
      end
    end

    describe '#flat_rate' do
      subject { create :flat_rate, value: 5.0 }
      before do
        allow(order).to receive(:subtotal).and_return 10
        allow(order).to receive(:tax).and_return 0.2
        allow(order).to receive(:shipping_price).and_return 0.5
      end

      it "subtracts from the order's total by #value" do
        expect(order.total).to eq 10 + 0.2 + 0.5

        subject.apply(order, nil)

        expect(order.total).to eq 10 + 0.2 + 0.5 - 5.0
      end
    end

    describe '#percent_off_job' do
      subject { create :flat_rate, value: 10 }
      let!(:job_1) { create(:order_job) }
      let!(:job_2) { create(:order_job) }

      before do
        job_1.line_items = [
          create(:non_imprintable_line_item, quantity: 1, unit_price: 7.0)
        ]

        job_2.line_items = [
          create(:non_imprintable_line_item, quantity: 2, unit_price: 5.0),
          create(:non_imprintable_line_item, quantity: 1, unit_price: 10.0)
        ]
        order.jobs << job_1
        order.jobs << job_2
      end

      it "reduces the total price of a single job from the order's subtotal" do
        expect(order.jobs.size).to eq 2
        expect(order.subtotal).to eq (1*7.0) + (2*5.0 + 1*10.0)

        subject.apply(order, job_2)

        expect(order.subtotal).to eq (1*7.0) + (2*5.0 + 1*10.0) - (2*5.0 + 1*10.0)*0.10
      end
    end

    describe 'free_shipping' do
      subject { create :free_shipping }
      before { order.update_column :shipping_price, 2.50 }

      it 'removes the shipping price from the order' do
        expect(order.shipping_price).to eq 2.50

        subject.apply(order)

        expect(order.shipping_price).to eq 0
      end
    end
  end
end
