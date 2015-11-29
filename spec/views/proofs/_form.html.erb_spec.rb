require 'spec_helper'

describe 'proofs/_form.html.erb', proof_spec: true do
  let!(:proof) { create(:valid_proof) }
  let!(:order) { proof.order }
  let!(:artwork_request) { create(:valid_artwork_request) }

  before do
    allow(order).to receive(:artworks).and_return [proof.artworks.first]
    allow(order).to receive(:artwork_requests).and_return [artwork_request]
  end

  it 'includes an approve_by field, image of artwork, job, and submit button' do
    render 'proofs/form', {order: order, proof: proof }
    expect(rendered).to have_selector('input#proof_approve_by')
    expect(rendered).to have_selector('select#proof_job_id')
    expect(rendered).to have_selector("img[src='#{proof.artworks.first.preview.file.url(:medium)}']")
    expect(rendered).to have_selector("input[type='submit']")
  end
end
