require 'spec_helper'

describe 'artwork_requests/_artwork_request.html.erb', artwork_request_spec: true do
  let!(:artwork_request) { create(:valid_artwork_request) }
  let!(:order) { build_stubbed(:blank_order) }
  let!(:artist) { build_stubbed(:user) }

  before(:each) do
    artwork_request.artist = artist
    render partial: 'artwork_requests/artwork_request', locals: { artwork_request: artwork_request, order: order }
  end

  context 'given a single artwork request' do

    it 'renders the full basic details, renders the artist job and style table' do 
      expect(rendered).to have_css('table.artist-job-and-style')
      expect(rendered).to have_css('dl.basic-artwork-request-details-short')
      expect(rendered).to have_css('dl.basic-artwork-request-details-full')
    end

    it 'renders a link to edit, to delete, reject artwork request, and add artwork' do 
      expect(rendered).to have_link('Delete', href: order_artwork_request_path(order, artwork_request) )
      expect(rendered).to have_link('Add Artwork', 
        href: artworks_path(artwork_request_id: artwork_request.id) )
      expect(rendered).to have_link('Reject Artwork Request', 
        href: order_artwork_request_path(artwork_request.order, artwork_request, 
          artwork_request: { state: 'reject_request'} ))
    end


    context 'state is pending_manager_approval' do
      before { allow(artwork_request).to receive(:state){'pending_manager_approval'} }

      it 'Renders a link to approve artwork or reject artwork', pending: 'Pending Manager Approval thing' do 
        expect(rendered).to have_link('Approve', 
        href: order_artwork_request_path(artwork_request.order, artwork_request, 
          artwork_request: { state: 'manager_approved'} ))

        expect(rendered).to have_link('Reject Artwork', 
        href: order_artwork_request_path(artwork_request.order, artwork_request, 
          artwork_request: { state: 'pending_artwork'} ))
      end
    end

    context 'state is not approved' do
      it 'Renders a link to reject artwork request' do 
        expect(rendered).to have_link('Reject Artwork Request', 
        href: order_artwork_request_path(artwork_request.order, artwork_request, 
          artwork_request: { state: 'reject_request'} ))
      end
    end

    context 'state is pending_manager_approval or manager_approved'

    context 'buttons are disabled fora modal' do
      it "doesn't render the add artwork button" 
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
end
