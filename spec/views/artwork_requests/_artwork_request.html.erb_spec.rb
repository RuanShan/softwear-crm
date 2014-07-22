require 'spec_helper'

describe 'artwork_requests/_artwork_request.html.erb', artwork_request_spec: true do
  let!(:artwork_request){ create(:valid_artwork_request) }
  let!(:order){ create(:order_with_job)}
  let!(:user){ create(:user)}

  before(:each) do
    current_user = build_stubbed(:blank_user)
    allow(current_user).to receive(:full_name).and_return('Stone Cold Steve Austin')
    render partial: 'artwork_requests/artwork_request', locals: {current_user: current_user, order: order, artwork_request: artwork_request}
  end

  context 'given a single artwork request' do
    it 'displays all the fields for the artwork request' do
      expect(rendered).to have_selector("div#artwork-request-#{artwork_request.id}")
      expect(rendered).to have_selector("div.the-notes")
      expect(rendered).to have_selector("h4.artwork-request-title")
      expect(rendered).to have_css("dt", text: 'Priority')
      expect(rendered).to have_css("dt", text: 'Imprint Method')
      expect(rendered).to have_css("dd", text: "#{artwork_request.imprint_method.name}")
      expect(rendered).to have_css("dt", text: 'Print Location')
      expect(rendered).to have_css("dd", text: "#{artwork_request.print_location.name}")
      expect(rendered).to have_css("dt", text: 'Ink Colors')
      expect(rendered).to have_css("dd", text: "#{artwork_request.ink_colors.collect { |x| [x.name] }.join(', ')}")
      expect(rendered).to have_css("dt", text: 'Imprintables')
      expect(rendered).to have_css("dt", text: 'Description')
      expect(rendered).to have_css("dd", text: "#{artwork_request.description.html_safe}")
      expect(rendered).to have_css("dt", text: 'Artwork Status')
      expect(rendered).to have_css("dd", text: "#{artwork_request.artwork_status}")
      expect(rendered).to have_css("dt", text: 'Deadline')
      expect(rendered).to have_css("dd", text: "#{artwork_request.deadline.strftime('%b %d, %Y, %I:%M %p')}")
      expect(rendered).to have_css("dt", text: 'Attachments')
      expect(rendered).to have_selector("a[href='/orders/#{order.id}/artwork_requests/#{artwork_request.id}/edit']")
      expect(rendered).to have_selector("a[data-method='delete']")
      expect(rendered).to have_selector("a[href='/orders/#{order.id}/artwork_requests/#{artwork_request.id}']")

    end
    it 'contains all of this information in a unique div' do

    end
  end
end