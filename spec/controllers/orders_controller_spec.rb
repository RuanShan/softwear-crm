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

  describe 'GET #names_numbers' do
    let(:order) { build_stubbed :order }

    it 'sends csv data' do
      allow(Order).to receive(:find).and_return order
      expect(order).to receive(:name_number_csv)

      get :names_numbers, id: order.id
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
    context 'given a valid packing slip' do
      let(:packing_slip) do
        fixture_file_upload('fba/TestPackingSlip.txt', 'text/text')
      end

      it 'calls FBA.parse_packing_slip on the file', basic: true do
        expect(FBA).to receive(:parse_packing_slip).and_call_original
        get :fba_job_info, packing_slips: [packing_slip], format: :js

        expect(response).to be_successful
      end

      context 'with options params' do
        it 'passes the params to FBA.parse_packing_slip' do
          expect(FBA).to receive(:parse_packing_slip)
            .with(anything, { imprintables: { '0705' => '5' } })

          get :fba_job_info,
               packing_slips: [packing_slip],
               options: { imprintables: { '0705' => '5' } },
               format: :js

          expect(response).to be_successful
        end
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
          phone_number: '123-456-8456',
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

    context 'with fba params', story_103: true do
      let(:order_params) do
        {
          name: 'Test FBA',
          terms: 'Fulfilled by Amazon'
        }
      end

      let(:fba_params) do
        {
          job_name: 'test_fba FBA222EE2E',
          imprintable: 500,
          colors: [
            {
              color: 500,
              sizes: [
                {
                  size: 500,
                  quantity: 10
                },
                {
                  size: 500,
                  quantity: 11
                },
                {
                  size: 500,
                  quantity: 12
                },
                {
                  size: 500,
                  quantity: 13
                }
              ]
            }
          ]
        }
      end

      it 'calls order#generate_jobs with' do
        dummy_order = double('Order')
        expect(Order).to receive(:create).and_return dummy_order
        expect(dummy_order).to receive(:valid?).and_return true
        expect(dummy_order).to receive(:generate_jobs)

        post :create, job_attributes: [fba_params.to_json], order: order_params
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
