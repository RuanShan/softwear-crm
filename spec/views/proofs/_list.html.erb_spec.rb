require 'spec_helper'

describe 'proofs/_list.html.erb', proof_spec: true do
  let!(:order) { build_stubbed(:blank_order) }

  before(:each) do
    allow(order).to receive(:requires_artwork?).and_return true
    render partial: 'proofs/list', locals: { order: order }
  end

  it 'has a div to contain all artwork_requests' do
    expect(rendered).to have_selector('div.proof-list')
  end

  it 'has a button to add artwork requests' do
    expect(rendered).to have_selector("a[href='#{new_order_proof_path(order)}']")
  end
end