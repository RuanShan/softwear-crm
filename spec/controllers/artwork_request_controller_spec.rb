require 'spec_helper'
include ApplicationHelper

describe ArtworkRequestsController, js: true, artwork_request_spec: true do

  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }
  let!(:artwork_request){ create(:valid_artwork_request) }
  let!(:order){ create(:order_with_job) }

  describe 'GET new' do
    it 'renders new.js.erb' do
      get :new, order_id: order.id, artwork_request_id: artwork_request.id, format: 'js'
      expect(response).to render_template('new')
    end
  end

  describe 'GET edit' do
    it 'renders edit.js.erb' do
      get :edit, order_id: order.id, id: artwork_request.id, format: 'js'
      expect(response).to render_template('edit')
    end
  end

  describe 'POST create' do
    it 'renders create.js.erb' do
      post :create, order_id: order.id, artwork_request_id: artwork_request.id, format: 'js'
      expect(response).to render_template('create')
    end
  end

  describe 'DELETE destroy' do
    it 'renders destroy.js.erb' do
      delete :destroy, order_id: order.id, id: artwork_request.id, format: 'js'
      expect(response).to render_template('destroy')
    end
  end

  describe 'PUT update' do
    it 'renders update.js.erb' do
      put :update, order_id: order.id, id: artwork_request.id, format: 'js'
      expect(response).to render_template('update')
    end
  end
end