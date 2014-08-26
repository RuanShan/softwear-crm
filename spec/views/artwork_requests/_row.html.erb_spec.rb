require 'spec_helper'

describe 'artwork_requests/_row.html.erb', artwork_request_spec: true do
  let!(:artwork_request) { build_stubbed(:blank_artwork_request,
                                          jobs: [build_stubbed(:blank_job,
                                                                 order: build_stubbed(:blank_order))],
                                          imprint_method: build_stubbed(:blank_imprint_method),
                                          ink_colors: [build_stubbed(:blank_ink_color)]) }

  before(:each) do
    render partial: 'artwork_requests/row', locals: { artwork_request: artwork_request }
  end

  it 'has the artwork_request priority, a link to the order, deadline, order in hand by date,
      total quantity, imprint method name, no. of ink colors, payment terms, order name, and actions' do
    expect(rendered).to have_selector('td', text: "#{ArtworkRequest::PRIORITIES[artwork_request.priority.to_i]}")
    expect(rendered).to have_selector('td', text: "#{display_time(artwork_request.deadline)}")
    expect(rendered).to have_selector('td', text: "#{display_time(artwork_request.jobs.first.order.in_hand_by)}")
    expect(rendered).to have_selector('td', text: "#{artwork_request.total_quantity}")
    expect(rendered).to have_selector('td', text: "#{artwork_request.imprint_method.name}")
    expect(rendered).to have_selector('td', text: "#{artwork_request.ink_colors.count}")
    expect(rendered).to have_selector('td', text: "#{artwork_request.jobs.first.order.payment_status}")
    expect(rendered).to have_selector("a[href='#{edit_order_artwork_request_path(artwork_request.jobs.first.order, artwork_request)}']")
    expect(rendered).to have_selector("a[href='#{order_artwork_request_path(artwork_request.jobs.first.order, artwork_request)}?disable_buttons=true']")
    expect(rendered).to have_selector("a[href='#{order_artwork_request_path(artwork_request.jobs.first.order, artwork_request)}']")
  end
end