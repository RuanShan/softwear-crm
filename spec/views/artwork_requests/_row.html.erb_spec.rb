require 'spec_helper'

describe 'artwork_requests/_row.html.erb', artwork_request_spec: true do
  let!(:artwork_request) do
    build_stubbed(:blank_artwork_request).tap do |ar|
      allow(ar).to receive(:jobs).and_return [build_stubbed(:blank_job, jobbable: build_stubbed(:blank_order))]
      allow(ar).to receive(:imprint_methods).and_return [build_stubbed(:blank_imprint_method)]
      allow(ar).to receive(:ink_colors).and_return [build_stubbed(:blank_ink_color)]
      allow(ar).to receive(:imprints).and_return [build_stubbed(:valid_imprint, job: build_stubbed(:job))]
      allow(ar).to receive(:salesperson).and_return double('Salesperson', full_name: 'Bob Jones')
      allow(ar).to receive(:artist).and_return double('Artist', full_name: 'Leonardi Divinci')
    end
  end

  before(:each) do
    render partial: 'artwork_requests/row', locals: { artwork_request: artwork_request }
  end

  it 'has the artwork_request priority, a link to the order, deadline, order in hand by date,
      total quantity, imprint method name, no. of ink colors, payment terms, order name, and actions', was_failing: true do
    within("#artwork-request-row-#{artwork_request.id}") do
      expect(rendered).to have_selector 'td', text: ArtworkRequest::PRIORITIES[artwork_request.priority.to_i]
      expect(rendered).to have_selector 'td', text: display_time(artwork_request.deadline)
      expect(rendered).to have_selector 'td', text: display_time(artwork_request.jobs.first.order.in_hand_by)
      expect(rendered).to have_selector 'td', text: artwork_request.total_quantity
      expect(rendered).to have_selector 'td', text: artwork_request.imprint_method.name
      expect(rendered).to have_selector 'td', text: artwork_request.ink_colors.count
      expect(rendered).to have_text artwork_request.jobs.first.order.payment_status
      expect(rendered).to have_selector("a[href='#{edit_order_artwork_request_path(artwork_request.jobs.first.order, artwork_request)}']")
      expect(rendered).to have_selector("a[href='#{order_artwork_request_path(artwork_request.jobs.first.order, artwork_request)}?disable_buttons=true']")
      expect(rendered).to have_selector("a[href='#{order_artwork_request_path(artwork_request.jobs.first.order, artwork_request)}']")
    end
  end

  it 'includes the artist and salesperson', story_941: true do
    expect(rendered).to have_selector 'dt', text: 'Salesperson'
    expect(rendered).to have_selector 'dd', text: artwork_request.salesperson.full_name

    expect(rendered).to have_selector 'dt', text: 'Artist'
    expect(rendered).to have_selector 'dd', text: artwork_request.artist.full_name
  end
end
