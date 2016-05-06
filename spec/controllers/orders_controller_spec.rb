require 'spec_helper'

describe OrdersController, order_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'GET new' do
    context 'when supplied a quote_id' do
      let(:quote) { build_stubbed(:valid_quote) }

      before(:each) { expect(Quote).to receive(:find).and_return(quote) }

      it 'sets @order to contain relevant quote data' do
        get :new, quote_id: quote.id
        expect(assigns(:order).contact_id).to eq(quote.contact_id)
        expect(assigns(:order).company).to eq(quote.company)
        expect(assigns(:order).name).to eq(quote.name)
        expect(assigns(:order).store_id).to eq(quote.store_id)
      end

    end
  end

  describe 'GET #fba', story_103: true do
    it 'renders index where terms = Fulfilled by Amazon' do
      expect(Order).to receive(:fba).and_call_original
      get :fba

      expect(response).to be_successful
    end
  end

  describe 'GET #fba_job_info', story_103: true do
    context 'given a valid packing slip', story_957: true do
      let(:packing_slip) do
        fixture_file_upload('fba/TestPackingSlip.txt', 'text/text')
      end

      it 'calls FBA::parse_packing_slip on an uploaded file', basic: true do
        expect(FBA).to receive(:parse_packing_slip)
          .with(anything, filename: 'TestPackingSlip.txt', shipped_by_id: valid_user.id)
          .and_call_original

        get :fba_job_info, packing_slips: [packing_slip], format: :js

        expect(response).to be_successful
      end

      it 'calls FBA::parse_packing_slip on a given url', url: true do
        extend WebMock

        stub_request(:get, "http://amazon.com/packing-slip/test.txt")
          .to_return(status: 200, body: "#{packing_slip.read}")

        expect(FBA).to receive(:parse_packing_slip)
          .with(anything, filename: 'test.txt', shipped_by_id: valid_user.id)
          .and_call_original

        get :fba_job_info, packing_slip_urls: 'http://amazon.com/packing-slip/test.txt', format: :js

        expect(response).to be_successful
      end
    end
  end

  describe 'POST #create', create: true do
    context 'with quote_ids', story_48: true do
      let!(:quote) { create :valid_quote }

      it 'assigns order.quote_ids to the given ids' do
        order_params = {
          name: 'Test Order',
          firstname: 'Test',
          lastname: 'Tlast',
          email: 'test@test.com',
          twitter: '@test',
          in_hand_by: '1/2/2015 12:00 PM',
          terms: 'Half down on purchase',
          tax_exempt: false,
          delivery_method: 'Ship to one location',
          contact_id: create(:crm_contact).id,
          store_id: 1,
          salesperson_id: 1,

          quote_ids: [quote.id]
        }

        expect_any_instance_of(Order)
          .to receive(:quote_ids=)
          .with [quote.id.to_s]

        post :create, order: order_params
      end
    end
  end

  describe 'POST #send_to_production', story_961: true do
    before do
      allow(Order).to receive(:find).with(order.id.to_s).and_return order
    end

    context 'when an order does not have a production order' do
      let!(:order) { create(:order) }

      it 'enqueues Order#create_production_order and sets a flash notice' do
        expect(order).to receive(:enqueue_create_production_order)
        post :send_to_production, id: order.id
        expect(flash[:success]).to eq "This order should appear in SoftWEAR Production within the next few minutes."
      end
    end

    context 'when an order already has a production order' do
      let!(:prod_order) { create(:production_order) }
      let!(:order) { create(:order, softwear_prod_id: prod_order.id) }

      it 'sets a flash error' do
        expect(order).to_not receive(:enqueue_create_production_order)
        allow(order).to receive(:production_url).and_return 'http://production-location.com/'
        post :send_to_production, id: order.id
        expect(flash[:error]).to eq "This order already has a Production entry: http://production-location.com/"
      end
    end
  end
end
