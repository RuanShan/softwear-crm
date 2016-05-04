require 'spec_helper'

describe ArtistMailer do

  describe 'artist_notification' do
    let!(:artwork_request) { create(:valid_artwork_request_with_artist) }
    let!(:action_name) { 'create' }
    let!(:mailer) { ArtistMailer.artist_notification(artwork_request, action_name) }

    it 'renders the subject' do
      expect(mailer.subject).to eql('Notification regarding your Artwork Requests')
    end

    it 'renders the receiver email' do
      expect(mailer.to).to eql([artwork_request.artist.email])
    end

    it 'renders the sender email' do
      expect(mailer.from).to eql(['noreply@softwearcrm.com'])
    end

    it 'assigns @salesperson' do
      expect(mailer.body.encoded).to match(artwork_request.salesperson.full_name)
    end

    it 'displays imprint info' do
      expect(mailer.body.encoded).to include(artwork_request.imprints.first.imprint_method.name)
      expect(mailer.body.encoded).to include(artwork_request.imprints.first.print_location.name)
      expect(mailer.body.encoded).to include(artwork_request.imprints.first.description)
    end

    it 'assigns @action_name' do
      expect(mailer.body.encoded).to match(action_name)
    end
  end
end
