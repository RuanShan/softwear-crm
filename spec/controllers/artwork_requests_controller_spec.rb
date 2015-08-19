require 'spec_helper'
include ApplicationHelper

describe ArtworkRequestsController, js: true, artwork_request_spec: true do
  let!(:order) { create(:order_with_job) }
  let!(:valid_user) { create :alternate_user }
  before(:each) do
    sign_in valid_user
    order.jobs.first.imprints << create(:valid_imprint)
  end

  describe 'POST create' do
    let(:imprint_method) { create(:valid_imprint_method_with_color_and_location) }
    let(:artwork_request) { attributes_for(:valid_artwork_request)
      .merge(artist_id: create(:user).id,
             salesperson_id: create(:alternate_user).id,
             imprint_ids: order.imprint_ids,
             ink_color_ids: imprint_method.ink_color_ids) }

    it 'renders create.js.erb' do
      post :create, order_id: order.id, artwork_request: artwork_request, format: 'js'
      expect(response).to render_template('create')
    end

    it 'sends an email to the artist', email: true do
      expect{ ArtistMailer.delay.artist_notification(artwork_request, 'create') }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)

      expect{ (post :create, order_id: order.id, artwork_request: artwork_request, format: 'js') }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
    end
  end

  describe 'PUT update' do
    let(:artwork) { create(:valid_artwork) }
    let(:artwork_request) { create(:valid_artwork_request) }

    context 'params[:artwork_id] is nil' do
      it 'renders update.js.erb' do
        put :update, order_id: order.id, id: artwork_request.id,
                     artwork_request: artwork_request, format: 'js'
        expect(response).to render_template('update')
      end

      it 'sends an email to the artist' do
        expect{ ArtistMailer.delay.artist_notification(artwork_request, 'update') }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
        expect{ (put :update, order_id: order.id, id: artwork_request.id,
                     artwork_request: artwork_request, format: 'js') }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)


      end
    end

    context 'params[:artwork_id] is not nil' do
      it 'assigns @artwork_request, @artwork, and @order' do
        put :update, id: artwork_request.id, artwork_id: artwork.id, format: 'js'
        expect(assigns[:artwork_request]).to eq ArtworkRequest.find(artwork_request.id)
        expect(assigns[:artwork]).to eq Artwork.find(artwork.id)
        expect(assigns[:order]).to eq Order.find(artwork_request.jobs.first.order.id)
      end

      context '[:remove_artwork] is true' do
        it 'renders update.js.erb and removes the artwork from the artwork request' do
          put :update, id: artwork_request.id, remove_artwork: true,
                       artwork_id: artwork.id, format: 'js'
          expect(response).to render_template('update')
          expect(artwork_request.artworks).to be_empty
        end

        it 'does not send an email to the artist' do
          expect(ArtistMailer).to_not receive(:artist_notification)
          put :update, id: artwork_request.id, remove_artwork: true,
                       artwork_id: artwork.id, format: 'js'
        end
      end
      context '[:remove_artwork] is nil'
    end

    context 'params[:artwork_id] is not nil and ' do
      it 'renders update.js.erb and adds the artwork to the artwork request' do
        put :update, id: artwork_request.id , artwork_id: artwork.id, format: 'js'
        expect(response).to render_template('update')
        expect(artwork_request.artworks).to_not be_empty
      end

      it 'does not send an email to the artist' do
        expect(ArtistMailer).to_not receive(:artist_notification).with(artwork_request, 'update')
        put :update, id: artwork_request.id, artwork_id: artwork.id, format: 'js'
      end
    end
  end
end
