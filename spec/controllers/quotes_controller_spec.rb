require 'spec_helper'
include ApplicationHelper

describe QuotesController, js: true, quotes_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'GET new' do
    it 'assigns the current user' do
      get :new
      expect(assigns(:current_user)).to eq(valid_user)
    end
  end

  describe 'GET edit' do
    let!(:valid_quote) { create(:valid_quote) }
    it 'assigns the current user' do
      get :edit, :id => valid_quote.id
      expect(assigns(:current_user)).to eq(valid_user)
    end
  end

end
