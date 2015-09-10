require 'spec_helper'

describe DiscountsController do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }
  let(:order) { create(:order) }

  describe 'POST #create', story_859: true do
    context 'when passed in_store_credit_ids' do
      let!(:in_store_credit_1) { create(:in_store_credit, amount: 20.0) }
      let!(:in_store_credit_2) { create(:in_store_credit, amount: 14.9) }

      before do
        post :create, format: :js,
          order_id: order.id,
          in_store_credit_ids: [in_store_credit_1.id, in_store_credit_2.id],
          discount: {
            amount: 22,
            discount_method: 'PayPal',
            user_id: valid_user.id,
            discountable_type: 'Order',
            discountable_id: order.id
          }
      end

      it 'creates a discount for each in store credit id' do
        expect(Discount.where(applicator: in_store_credit_1)).to exist
        expect(Discount.where(applicator: in_store_credit_2)).to exist

        expect(
          Discount.where(
            applicator: in_store_credit_1,
            amount: 22,
            discount_method: 'PayPal'
          )
        ).to exist
        expect(
          Discount.where(
            applicator: in_store_credit_2,
            amount: 22,
            discount_method: 'PayPal'
          )
        ).to exist
      end
    end
  end
end
