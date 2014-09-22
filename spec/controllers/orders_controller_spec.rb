require 'spec_helper'

describe OrdersController, order_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'POST new' do
    context 'when supplied a quote_id' do
      let(:quote) { build_stubbed(:valid_quote) }

      it 'sets @order to contain relevant quote data' do
        expect(Quote).to receive(:find).and_return(quote)
        get :new, quote_id: quote.id
        expect(assigns(:order).email).to eq(quote.email)
        expect(assigns(:order).phone_number).to eq(quote.phone_number)
        expect(assigns(:order).firstname).to eq(quote.first_name)
        expect(assigns(:order).lastname).to eq(quote.last_name)
        expect(assigns(:order).company).to eq(quote.company)
        expect(assigns(:order).twitter).to eq(quote.twitter)
        expect(assigns(:order).name).to eq(quote.name)
        expect(assigns(:order).store_id).to eq(quote.store_id)
      end
    end
  end
end
