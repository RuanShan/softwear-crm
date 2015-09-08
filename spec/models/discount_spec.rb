require 'spec_helper'

describe Discount, story_859: true do
  describe 'when applicator is a coupon' do
    let!(:coupon) { create(:percent_off_order) }
    let!(:discount) { create(:discount_with_order) }

    it 'assigns #amount to applicator#calculate(order)' do
      allow_any_instance_of(Coupon).to receive(:calculate)
        .with(kind_of(Order))
        .and_return 10
      discount.applicator = coupon
      discount.save!

      expect(discount.amount).to eq 10
    end
  end
end
