require 'spec_helper'

describe OrdersController, order_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  context '#names_numbers' do
    let(:order) { build_stubbed :order }

    it 'sends csv data' do
      allow(Order).to receive(:find).and_return order
      expect(order).to receive(:name_number_csv)

      get :names_numbers, id: order.id
    end
  end
end
