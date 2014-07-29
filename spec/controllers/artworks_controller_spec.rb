require 'spec_helper'
include ApplicationHelper

describe ArtworksController, js: true, artworks_spec: true do

  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }
  let!(:artwork){ create(:valid_artwork) }

  describe 'GET show' do

    it 'renders show.js.erb' do
      get :show, id: artwork.id, format: 'js'
      expect(response).to render_template('show')
    end
  end

  describe 'GET index' do
    it 'renders index.js.erb regardless of whether artwork_request is nil or defined' do
      get :index, id: artwork.id, artwork_request: nil, format: 'js'
      expect(response).to render_template('index')
      get :index, id: artwork.id, artwork_request: create(:valid_artwork_request), format: 'js'
      expect(response).to render_template('index')
    end
  end

  describe 'GET new' do
    it 'renders new.js.erb' do
      get :new, id: artwork.id, format: 'js'
    end
  end

  describe 'GET edit' do
    it 'renders edit.js.erb' do
      get :edit, id: artwork.id, format: 'js'
      expect(response).to render_template('edit')
    end
  end

  describe 'DELETE destroy' do
    it 'renders destroy.js.erb' do
      delete :destroy, id: artwork.id, format: 'js'
      expect(response).to render_template('destroy')
    end
  end

  describe 'POST create' do
    context 'with valid input' do
      it 'renders create.js.erb' do
        post :create, artwork: attributes_for(:valid_artwork), format: 'js'
        expect(response).to render_template('create')
        expect(Artwork.where(id: artwork.id)).to exist
      end
    end
  end

  describe 'PUT update' do
    context 'with valid input' do
      it 'renders update.js.erb' do
        put :update, id: artwork.id, artwork: attributes_for(:valid_artwork), format: 'js'
        expect(response).to render_template('update')
        expect(Artwork.where(id: artwork.id)).to exist
      end
    end
  end
end