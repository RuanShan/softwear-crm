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

  describe 'POST #create' do
    context 'with fba params', story_103: true do
      let(:fba_params) do
        [
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
        ]
      end
      
      it 'calls order#generate_jobs with' do
        expect_any_instance_of(Order).to receive(:generate_jobs)
          .with(fba_params)

        post :create, job_attributes: fba_params.to_json

        expect(response).to be_successful
      end
    end
  end
end
