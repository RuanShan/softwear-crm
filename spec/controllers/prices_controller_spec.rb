require 'spec_helper'
include ApplicationHelper

describe PricesController, js: true, prices_spec: true do
  let!(:valid_user) { create :alternate_user }
  let!(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    sign_in valid_user
    allow_any_instance_of(Imprintable).to receive(:name).and_return('Name')
  end

  describe 'GET new' do
    before(:each) do
      expect(Imprintable).to receive(:find).and_return(imprintable)
    end

    it 'assigns @imprintable' do
      get :new, { id: imprintable.id, format: 'js' }
      expect(assigns(:imprintable)).to eq(imprintable)
    end
  end

  describe 'POST create' do
    before(:each) do
      expect(Imprintable).to receive(:find).and_return(imprintable)
    end

    it 'assigns @imprintable' do
      post :create, { decoration_price: 4, id: imprintable.id, format: 'js' }
      expect(assigns(:imprintable)).to eq(imprintable)
    end

    it 'adds the imprintable hash to the pricing table in session' do
      expect(session[:prices]).to be_nil
      post :create, { decoration_price: 4, id: imprintable.id, format: 'js' }
      expect(session[:prices].first).to eq(imprintable.pricing_hash(4))
    end
  end

  context 'session[:pricing_hash] contains 2 different prices' do
    before(:each) do
      session[:prices] = []
      session[:prices] << imprintable.pricing_hash(3)
      session[:prices] << imprintable.pricing_hash(1)
    end

    describe 'GET destroy' do
      it 'removes only one element from session[:prices]' do
        expect(session[:prices].size).to eq(2)
        get :destroy, { id: 0, format: 'js' }
        expect(session[:prices].size).to eq(1)
        expect(session[:prices].first).to eq(imprintable.pricing_hash(1))
      end
    end

    describe 'GET destroy_all' do
      it 'removes all the elements from session[:prices]' do
        expect(session[:prices].size).to eq(2)
        get :destroy_all, { format: 'js' }
        expect(session[:prices].size).to eq(0)
      end
    end
  end
end
