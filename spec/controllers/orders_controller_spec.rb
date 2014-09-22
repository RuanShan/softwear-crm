require 'spec_helper'

describe OrdersController, pending: true, order_spec: true do
  describe '#name_number_csv', n_n_csv: true do
    let(:order) { create :order }

    it 'sends csv data' do
      allow(Order).to receive(:find).and_return order
      expect(order).to receive(:name_number_csv)

      get :name_number_csv, id: order.id
    end
  end
end
