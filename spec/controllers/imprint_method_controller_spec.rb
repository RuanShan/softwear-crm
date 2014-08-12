require 'spec_helper'

describe ImprintMethodsController, imprint_methods_spec: true do

  let!(:imprint_method) { create :valid_imprint_method }
  let(:print_location) { create :valid_print_location, imprint_method_id: imprint_method.id }
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'GET print_locations' do
    it 'assigns @imprint_method, @print_locations, and renders _print_locations_select.html.erb' do
      print_location
      get :print_locations, imprint_method_id: imprint_method.id
      expect(assigns[:imprint_method]).to eq imprint_method
      expect(assigns[:print_locations]).to eq [print_location]
      expect(response).to render_template(partial: '_print_locations_select')
    end
  end

  describe 'GET show' do
    context 'format is HTML' do
      it 'redirects to edit' do
        get :show, id: imprint_method.to_param
        expect(response).to redirect_to(edit_imprint_method_path(imprint_method.to_param))
      end
    end
    context 'format is Javascript' do
      it 'renders show.js.erb' do
        get :show, id: imprint_method.to_param, format: 'js'
        expect(response).to render_template('show')
      end
    end
  end

  describe 'PUT update' do
    context 'with valid input' do
      it 'updates an imprint method' do
        expect{put :update, id: imprint_method.to_param, imprint_method: attributes_for(:valid_imprint_method)}.to_not change(ImprintMethod, :count)
      end
    end

    context 'with invalid input' do
      it 'renders edit.html.erb' do
        get :edit, id: imprint_method.to_param
        expect(response).to render_template('imprint_methods/edit')
      end
    end
  end
end