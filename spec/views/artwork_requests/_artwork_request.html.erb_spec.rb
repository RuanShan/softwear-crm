require 'spec_helper'

describe 'artwork_requests/_artwork_request.html.erb', artwork_request_spec: true do
  let!(:artwork_request) { create(:valid_artwork_request) }
  let!(:order) { build_stubbed(:blank_order) }
  let!(:artist) { build_stubbed(:user) }

  before(:each) do
    artwork_request.artist = artist
  end

  context 'regardless of available transitions' do
    before { render 'artwork_requests/artwork_request', {artwork_request: artwork_request, order: order} }
    it 'renders the full basic details, renders the artist job and style table' do
      expect(rendered).to have_css('table.artist-job-and-style')
      expect(rendered).to have_css('dl.basic-artwork-request-details-short')
      expect(rendered).to have_css('dl.basic-artwork-request-details-full')
    end

    it 'renders a link to edit, to delete, reject artwork request, and add artwork' do
      expect(rendered).to have_link('Edit',
                                    href: edit_order_artwork_request_path(order, artwork_request) )
      expect(rendered).to have_link('Add Artwork',
        href: artworks_path(artwork_request_id: artwork_request.id) )
    end

    context 'when it is an exact reorder' do
      let(:artwork_request) { create(:valid_artwork_request, reorder: true) }

      it 'renders a warning that it is an exact reorder' do
        expect(rendered).to have_css('.alert-warning', text: "This artwork request is for an exact reorder")
      end
    end

    context 'when an asset is attached' do
      let!(:artwork_request) { create(:valid_artwork_request_with_asset) }

      it 'displays the fields for the asset' do
        expect(rendered).to have_css('dt', text: 'Attachments:')
        expect(rendered).to have_selector('div.indent')
        expect(rendered).to have_css('dd', text: "#{artwork_request.assets.first.file_file_name}")
        expect(rendered).to have_css('dd', text: "#{number_to_human_size(artwork_request.assets.first.file_file_size)}")
        expect(rendered).to have_css('dd', text: "#{artwork_request.assets.first.description}")
        expect(rendered).to have_selector("a[href='#{artwork_request.assets.first.file.url}']")
      end
    end

    context 'when an artwork is attached' do
      let!(:artwork_request) { create(:valid_artwork_request_with_artwork) }

      it 'displays the fields for the artwork', slow: true do
        expect(rendered).to have_selector('h4.artwork-title')
        expect(rendered).to have_css('dt', text: 'Name:')
        expect(rendered).to have_css('dd', text: "#{artwork_request.artworks.first.name}")
        expect(rendered).to have_selector("img[src='#{artwork_request.artworks.first.preview.file.url(:medium)}']")
        expect(rendered).to have_selector("a[href='#{artwork_request_path(id: artwork_request.id, remove_artwork: true, artwork_id: artwork_request.artworks.first.id)}']")
        expect(rendered).to have_css('dt', text: 'Created By:')
        expect(rendered).to have_css('dd', text: "#{artwork_request.artworks.first.artist.full_name}")
        expect(rendered).to have_css('dt', text: 'Description:')
        expect(rendered).to have_css('dd', text: "#{artwork_request.artworks.first.description}")
      end
    end
  end

  context "when it can't transition to a given state" do
    before do
      allow(artwork_request).to receive(:can_approved?) { false }
      allow(artwork_request).to receive(:can_revise_artwork_request?) { false }
      allow(artwork_request).to receive(:can_reject_artwork?) { false }
      allow(artwork_request).to receive(:can_reject_artwork_request?) { false }
      render 'artwork_requests/artwork_request', {artwork_request: artwork_request, order: order}
    end

    it "doesn't render the links to transition" do
      expect(rendered).to_not have_link 'Approve Artwork'
      expect(rendered).to_not have_link 'Mark Artwork Request Revised'
      expect(rendered).to_not have_css(:href, 'Reject Artwork')
      expect(rendered).to_not have_css(:href, 'Reject Artwork Request')
    end
  end

  context 'when it can transition to a given state' do
    before do
      allow_any_instance_of(ArtworkRequest).to receive(:can_approved?) { true }
      allow_any_instance_of(ArtworkRequest).to receive(:can_revise_artwork_request?) { true }
      allow_any_instance_of(ArtworkRequest).to receive(:can_reject_artwork?) { true }
      allow_any_instance_of(ArtworkRequest).to receive(:can_reject_artwork_request?) { true }
      render 'artwork_requests/artwork_request', {artwork_request: artwork_request, order: order}
    end

    it 'does render the links to transition' do
      expect(rendered).to have_link 'Approve Artwork'
      expect(rendered).to have_link 'Mark Artwork Request Revised'
      expect(rendered).to have_link 'Reject Artwork'
      expect(rendered).to have_link 'Reject Artwork Request'
    end
  end
end
