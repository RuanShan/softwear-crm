require 'spec_helper'

describe 'proofs/_form.html.erb', proof_spec: true do
  let!(:order){ Order.find(proof.order_id) }
  let!(:proof){ create(:valid_proof) }

  it 'displays the correct form fields for proofs', pending: 'Figure out how to deal with order has_many artwork_requests :through jobs in factories' do
    form_for(proof, url: order_proofs_path(order, proof)){ |f| @f = f }
    render partial: 'proofs/form', locals: { f: @f, order: order, proof: Proof.new }
    within_form_for Proof do
      expect(rendered).to have_selector('input#proof_approve_by')
      expect(rendered).to have_selector("input[name='proof[artwork_ids][]']")
      expect(rendered).to have_selector("img[src='#{proof.artworks.first.preview.file.url}']")
      expect(rendered).to have_selector('i.proof-mockups')
      expect(rendered).to have_selector("input[type='submit']")
    end
  end
end