require 'spec_helper'

describe 'artwork_requests/_row.html.erb', artwork_requests_spec: true do
  let!(:artwork_request) { create(:valid_artwork_request) }
  before(:each) do
    render partial: 'artwork_requests/row', locals: {artwork_request: artwork_request}
  end

  it 'has the artwork_request priority, a link to the order, deadline, order in hand by date, total quantity, imprint method name, count of ink colors, payment status, and actions (edit, show, destroy) ' do
    expect(rendered).to have_selector('td', text: "#{ArtworkRequest::PRIORITIES[artwork_request.priority.to_i]}")
    expect(rendered).to have_selector('td', text: "#{artwork_request.deadline.strftime('%b %d, %Y, %I:%M %p')}")
    expect(rendered).to have_selector('td', text: "#{artwork_request.jobs[0].order.in_hand_by.strftime('%b %d, %Y, %I:%M %p')}")
    expect(rendered).to have_selector('td', text: "#{artwork_request.total_quantity}")
    expect(rendered).to have_selector('td', text: "#{artwork_request.imprint_method.name}")
    expect(rendered).to have_selector('td', text: "#{artwork_request.ink_colors.count}")
    expect(rendered).to have_selector('td', text: "#{artwork_request.jobs[0].order.payment_status}")
    expect(rendered).to have_selector("a[href='#{edit_order_artwork_request_path(artwork_request.jobs[0].order, artwork_request)}']")
    expect(rendered).to have_selector("a[href='#{order_artwork_request_path(artwork_request.jobs[0].order, artwork_request)}?disable_buttons=true']")
    expect(rendered).to have_selector("a[href='#{order_artwork_request_path(artwork_request.jobs[0].order, artwork_request)}']")
  end
end