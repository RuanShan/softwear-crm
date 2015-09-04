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
  end
end
