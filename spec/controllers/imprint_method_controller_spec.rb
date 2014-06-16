require 'spec_helper'

describe ImprintMethodsController do

  let!(:imprint_method) { create :valid_imprint_method }
  let(:print_location) { create :print_location, imprint_method_id: imprint_method.id }
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'GET print_locations' do
    it 'assigns @print_locations' do
      print_location
      get :print_locations, imprint_method_id: imprint_method.id
      expect(assigns[:print_locations]).to eq [print_location]
    end
  end

  describe 'GET index' do
    it 'assigns @imprint_methods' do
      get :index
      expect(assigns(:imprint_methods)).to eq([imprint_method])
    end

    it 'renders index.html.erb' do
      get :index
      expect(response).to render_template('imprint_methods/index')
    end
  end

  describe 'GET show' do
    it 'redirects to edit' do
      get :show, id: imprint_method.to_param
      expect(response).to redirect_to(edit_imprint_method_path(imprint_method.to_param))
    end
  end

  describe 'GET new' do
    it 'renders new.html.erb' do
      get :new
      expect(response).to render_template('imprint_methods/new')
    end
  end

  describe 'GET edit' do
    it 'renders edit.html.erb' do
      get :edit, id: imprint_method.to_param
      expect(response).to render_template('imprint_methods/edit')
    end
  end

  describe 'POST create' do
     context 'with valid input' do
       it 'creates a new imprint method' do
         expect{post :create, imprint_method: attributes_for(:valid_imprint_method)}.to change(ImprintMethod, :count).by(1)
         expect(imprint_method.name).to eq('Imprint Method')
      end
     end

    context 'with invalid input' do
      it 'renders new.html.erb' do
        get :new
        expect(response).to render_template('imprint_methods/new')
      end
    end
  end

  describe 'PUT update' do
    context 'with valid input' do
      it 'updates a new imprint method' do
        expect{put :update, id: imprint_method.to_param, imprint_method: attributes_for(:valid_imprint_method)}.to_not change(ImprintMethod, :count)
        expect(imprint_method.name).to eq('Imprint Method')
      end
    end

    context 'with invalid input' do
      it 'renders edit.html.erb' do
        get :edit, id: imprint_method.to_param
        expect(response).to render_template('imprint_methods/edit')
      end
    end
  end


  describe 'DELETE destroy' do
    it 'deletes the contact' do
    expect{delete :destroy, id: imprint_method.to_param}.to change(ImprintMethod, :count).by(-1)
    end
  end

end