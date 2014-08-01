require 'spec_helper'

describe 'proofs/_list.html.erb', proof_spec: true do
  let!(:order){ create(:order_with_proofs)}

  before(:each) do
    render partial: 'proofs/list', locals: { order: order }
  end

  it 'has a div to contain all artwork_requests' do
    expect(rendered).to have_selector("div.proof-list")
  end

  it 'has a button to add artwork requests' do
    expect(rendered).to have_selector("a#new_proof")
  end
end