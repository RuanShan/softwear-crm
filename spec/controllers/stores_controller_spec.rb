require 'spec_helper'

describe StoresController do
  let(:store) { create(:valid_store) }
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'GET index' do

    it 'assigns Stores' do
      get :index
      expect(assigns(:stores)).to eq([store])
    end
  end

  describe 'PUT update' do
    it 'redirects to index' do
      put :update, id: store.to_param, params: attributes_for(:valid_store)
      expect(response).to redirect_to(stores_path)
    end
  end

  describe 'GET show' do
    it 'redirects to index' do
      get :show, id: store.to_param
      expect(response).to redirect_to(stores_path)
    end
  end

end