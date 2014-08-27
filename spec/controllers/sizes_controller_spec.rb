require 'spec_helper'
include ApplicationHelper

describe SizesController, js: true, size_spec: true do
  let!(:valid_user) { create(:alternate_user) }
  let!(:size) { create(:valid_size) }
  before(:each) { sign_in valid_user }

  describe 'PATCH update' do
    before(:each) { patch :update, ** new_values, id: size.id }

    context 'with valid parameters' do
      let(:new_values) { attributes_for(:valid_size) }

      it 'redirects to brands_path' do
        expect(response).to redirect_to sizes_path
      end
    end

    context 'with invalid parameters' do
      let(:new_values) { attributes_for(:blank_size) }

      it 'renders edit action' do
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'GET show' do
    it 'redirects' do
      get :show, id: size.id
      expect(response).to redirect_to edit_size_path size.id
    end
  end

  describe 'POST update_size_order' do
    before(:each) do
      d = double(update: 'something')
      expect(Size).to receive(:find).with('2').and_return(d)
    end

    it 'updates the proper size' do
      post :update_size_order, categories: ['size_2']
    end
  end
end
