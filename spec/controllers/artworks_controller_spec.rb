require 'spec_helper'
include ApplicationHelper

describe ArtworksController, js: true, artwork_spec: true do

  let!(:artwork) { create(:valid_artwork) }
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'GET index' do
    it 'assigns @artworks, @artwork_request, and renders index.js.erb' do
      get :index, id: artwork.id, artwork_request: nil, format: 'js'
      expect(assigns[:artworks]).to eq Artwork.all.page
      expect(assigns[:artwork_request]).to eq nil
      expect(response).to render_template('index')
    end
  end
end
