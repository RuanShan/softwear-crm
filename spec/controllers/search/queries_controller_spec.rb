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

  let(:test_params_with_metadata) do
    {search: {
      order: {
        '1' => { firstname: 'Nigel', _metadata: [:negate] },
        '2' => { lastname: 'Baillie' },
        '3' => { commission_amount: 15.00, _metadata: [:greater_than] },
        fulltext: 'ftestasdlfkj'
    }}}
  end

  # let(:test_params_with_group) do
  #   {search: {
  #     order: {
  #       '1' => { firstname: 'Someone' }
  #       
  #   }}}
  # end

  let(:query) { create(:search_query) }
  let(:order_model) { create(:query_order_model, query: query, default_fulltext: 'success') }
  let(:job_model) { create(:query_job_model, query: query, default_fulltext: 'testing') }

  context 'GET' do
    describe '#search' do
      context 'when params contains a query id' do
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
    describe '#update', :update do
      it 'updates the given query with the given filter info' do
        job_model.filter = create(:filter_group)
        job_model.filter.filters << create(:string_filter, field: 'name')
        query.save

        expect(Search::QueryModel.count).to eq 1

        put :update, {id: query.id}.merge(test_params)
        expect(response).to be_ok

        expect(assigns[:query]).to eq query
        expect(Search::QueryModel.count).to eq 1
        expect(query.query_models.first.filter.filters.count).to eq 2
      end
    end
  end

  context 'POST' do
    describe '#create' do
      it 'creates a new query with the given filter info' do
        post :create, test_params
        expect(response).to be_ok

        expect(assigns[:query]).to be_a Search::Query
        expect(assigns[:query].query_models.first.name).to eq 'Order'

        expect(assigns[:query].query_models.first.filter.filters.first.field).to eq 'lastname'
      end
    end
  end

  context 'DELETE' do
    describe '#destroy' do
      it 'destroys the query' do
        delete :destroy, id: query.id
        expect(Search::Query.count).to eq 0
      end
    end
  end
end