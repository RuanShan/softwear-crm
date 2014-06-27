require 'spec_helper'

describe Search::QueriesController, search_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  let(:test_params) do
    {search: {
        order: {
          '1' => { lastname: 'Johnson' },
          '2' => { commission_amount: 200 },
          fulltext: 'test'
    }}}
  end

  context 'GET' do
    describe '#search' do
      context 'when params contains a query id' do
        let!(:query) { create(:search_query, default_fulltext: 'success') }
        let!(:order_model) { create(:query_order_model, query: query) }
        before(:each) do
          order_model.filter = create(:filter_group)
          order_model.filter.filters << create(:string_filter)
          query.save
        end

        it 'searches with that query' do
          get :search, query_id: query.id
          expect(response).to be_ok

          expect(assigns[:search].first).to be_a Sunspot::Search::StandardSearch

          expect(Sunspot.session).to be_a_search_for Order
          expect(Sunspot.session).to have_search_params(:fulltext, 'success')
          expect(Sunspot.session).to have_search_params(:with, :firstname, 'Test')
        end
      end

      context 'when params contains search info' do
        it 'searches with the given filter info' do
          get :search, test_params
          expect(response).to be_ok

          expect(assigns[:search].first).to be_a Sunspot::Search::StandardSearch

          expect(Sunspot.session).to be_a_search_for Order
          expect(Sunspot.session).to have_search_params(:fulltext, 'test')
          expect(Sunspot.session).to have_search_params(:with, :lastname, 'Johnson')
          expect(Sunspot.session).to have_search_params(:with, :commission_amount, 200)
        end
      end
    end
  end

  context 'PUT' do
    describe '#update' do
      it 'updates the given query with the given filter info'
    end
  end

  context 'POST' do
    describe '#create' do
      it 'creates a new query with the given filter info' do
        post :create, test_params
        expect(response).to be_ok

        expect(assigns[:query]).to be_a Search::Query
        expect(assigns[:query].query_models.first.name).to eq 'Order'

        expect(assigns[:query].query_models.first.filter.first.field).to eq 'lastname'
      end
    end
  end
end