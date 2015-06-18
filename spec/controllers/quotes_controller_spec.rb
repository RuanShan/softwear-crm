require 'spec_helper'
include ApplicationHelper

describe QuotesController, js: true, quote_spec: true do
  let!(:valid_user) { create :alternate_user }
  let!(:quote) { create :valid_quote }

  before(:each) { sign_in valid_user }

  describe 'GET new' do
    before(:each) { get :new }

    it 'assigns the current action' do
      expect(assigns(:current_action)).to eq('quotes#new')
    end
  end

  describe 'GET index' do
    before(:each) { get :index }

    it 'assigns the current action' do
      expect(assigns(:current_action)).to eq('quotes#index')
    end
  end

  describe 'GET edit' do
    before(:each) do
      allow_any_instance_of(Quote).to receive(:all_activities).and_return(true)
      get :edit, id: quote.id
    end

    it 'assigns the current user' do
      expect(assigns(:current_user)).to eq(valid_user)
    end

    it 'assigns activities' do
      expect(assigns(:activities)).to eq(true)
    end

    it 'assigns current_action' do
      expect(assigns(:current_action)).to eq('quotes#edit')
    end
  end

  describe 'GET show' do
    it 'responds to json' do
      get :show, id: quote.id, format: :json
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['result']).to eq('success')
    end

    it 'responds to html' do
      get :show, id: quote.id, format: :html
      expect(response).to render_template('show')
    end
  end
end
