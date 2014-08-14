require 'spec_helper'

describe ColorsController, color_spec: true do
  let!(:valid_user) { create(:alternate_user) }
  let!(:color) { create(:valid_color) }
  before(:each) { sign_in valid_user }

  describe 'GET index' do
    it 'assigns colors' do
      get :index
      expect(assigns(:colors)).to eq([color])
    end
  end

  describe 'PATCH update' do
    before(:each) { patch :update, ** new_values, id: color.id }

    context 'with valid parameters' do
      let(:new_values) { attributes_for(:valid_color) }

      it 'redirects to colors_path' do
        expect(response).to redirect_to colors_path
      end
    end

    context 'with invalid parameters' do
      let(:new_values) { attributes_for(:blank_color) }

      it 'renders edit action' do
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'GET show' do
    it 'redirects to edit color path' do
      get :show, id: color.to_param
      expect(response).to redirect_to edit_color_path id: color.to_param
    end
  end

  describe '#set_current_action' do
    it 'assigns "colors" to @current_action' do
      controller.send(:set_current_action)
      expect(assigns(:current_action)).to eq('colors')
    end
  end
end
