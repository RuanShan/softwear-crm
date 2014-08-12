require 'spec_helper'

describe 'artwork_requests/_artwork_request.html.erb', artwork_request_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request) }
  let!(:order){ build_stubbed(:blank_order) }

  before(:each) do
    current_user = build_stubbed(:blank_user)
    allow(current_user).to receive(:full_name).and_return('Stone Cold Steve Austin')
    render partial: 'artwork_requests/artwork_request', locals: { artwork_request: artwork_request, current_user: current_user, order: order }
  end

  context 'given a single artwork request' do
    it 'displays all the fields for the artwork request' do
      expect(rendered).to have_selector("div#artwork-request-#{artwork_request.id}")
      expect(rendered).to have_selector('div.the-notes')
      expect(rendered).to have_selector('h4.artwork-request-title')
      expect(rendered).to have_css('dt', text: 'Priority:')
      expect(rendered).to have_css('dd', text: "#{ArtworkRequest::PRIORITIES[artwork_request.priority.to_i]}")
      expect(rendered).to have_css('dt', text: 'Imprint Method:')
      expect(rendered).to have_css('dd', text: "#{artwork_request.imprint_method.name}")
      expect(rendered).to have_css('dt', text: 'Print Location:')
      expect(rendered).to have_css('dd', text: "#{artwork_request.print_location.name}")
      expect(rendered).to have_css('dt', text: 'Ink Colors:')
      expect(rendered).to have_css('dd', text: "#{artwork_request.ink_colors.collect { |x| [x.name] }.join(', ')}")
      expect(rendered).to have_css('dt', text: 'Imprintables Included:')
      expect(rendered).to have_css('dd', text: "#{artwork_request.imprintable_info}")
      expect(rendered).to have_css('dt', text: 'No. of Pieces:')
      expect(rendered).to have_css('dd', text: "#{artwork_request.imprintable_variant_count}")
      expect(rendered).to have_css('dt', text: 'Description:')
      expect(rendered).to have_css('dd', text: "#{artwork_request.description.html_safe}")
      expect(rendered).to have_css('dt', text: 'Artwork Status:')
      expect(rendered).to have_css('dd', text: "#{artwork_request.artwork_status}")
      expect(rendered).to have_css('dt', text: 'Deadline:')
      expect(rendered).to have_css('dd', text: "#{display_time(artwork_request.deadline)}")
      expect(rendered).to have_css('dt', text: 'Salesperson:')
      expect(rendered).to have_css('dd', text: 'Stone Cold Steve Austin')
      expect(rendered).to have_css('dt', text: 'Artist:')
      expect(rendered).to have_css('dd', text: "#{artwork_request.artist.full_name}")
      expect(rendered).to have_css('dt', text: 'Attachments:')
      expect(rendered).to have_css('dd', text: 'None')
      expect(rendered).to have_css('dt', text: 'Max Print Area:')
      expect(rendered).to have_css('dd', text: "#{artwork_request.max_print_area(artwork_request.print_location)}")
      expect(rendered).to have_selector("a[href='#{artworks_path(artwork_request_id: artwork_request.id)}']")
      expect(rendered).to have_selector("a[href='#{edit_order_artwork_request_path(order, artwork_request)}']")
      expect(rendered).to have_selector("a[href='#{order_artwork_request_path(order, artwork_request)}']")
    end

    context 'when an asset is attached' do
      let!(:artwork_request){ create(:valid_artwork_request_with_asset) }

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
      let!(:artwork_request){ create(:valid_artwork_request_with_artwork) }

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