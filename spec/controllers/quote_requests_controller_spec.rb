require 'spec_helper'

describe QuoteRequestsController, quote_request_spec: true, story_207: true do

  let!(:quote_requests) { [create(:quote_request)] }
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'GET index' do
    it 'assigns @quote_requests and renders index' do
      get :index
      expect(assigns[:quote_requests]).to eq QuoteRequest.all.page
      expect(response).to render_template('index')
    end
  end
end
