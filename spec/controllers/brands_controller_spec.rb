require 'spec_helper'

describe BrandsController, brand_spec: true do
  let!(:valid_user) { create(:alternate_user) }
  let!(:brand) { create(:valid_brand) }
  before(:each) { sign_in valid_user }

  describe 'GET index' do
    it 'assigns brands' do
      get :index
      expect(assigns(:brands)).to eq([brand])
    end
  end

  describe 'PATCH update' do
    before(:each) { patch :update, ** new_values, id: brand.id }

    context 'with valid parameters' do
      let(:new_values) { attributes_for(:valid_brand) }

      it 'redirects to brands_path' do
        expect(response).to redirect_to brands_path
      end
    end

    context 'with invalid parameters' do
      let(:new_values) { attributes_for(:invalid_brand) }

      it 'renders edit action' do
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'GET show' do
      it 'redirects to edit brand path' do
        get :show, id: brand.to_param
        expect(response).to redirect_to edit_brand_path id: brand.to_param
      end
  end

  describe '#set_current_action' do
      it 'assigns "brands" to @current_action' do
        controller.send(:set_current_action)
        expect(assigns(:current_action)).to eq('brands')
      end
  end
end
