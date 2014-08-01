require 'spec_helper'

describe 'proofs/_proof.html.erb', proof_spec: true do


  before(:each) do
    render partial: 'proofs/proof', locals: {proof: proof, order: order}
  end
  context 'proof status is Pending' do
    let!(:proof){ create(:valid_proof) }
    let!(:order){ Order.find(proof.order_id) }
    it 'displays all of the info for a proof, edit, destroy, email customer, approve, and reject buttons, all in a unique div' do
      expect(rendered).to have_selector("div#proof-#{proof.id}")
      expect(rendered).to have_selector("div.proof-notes")
      expect(rendered).to have_selector("h4.proof-title")
      expect(rendered).to have_css("dt", text: 'Proof Status:')
      expect(rendered).to have_css("dd", text: "#{proof.status}")
      expect(rendered).to have_css("dt", text: 'Approve By:')
      expect(rendered).to have_css("dd", text: "#{proof.approve_by.strftime('%b %d, %Y, %I:%M %p')}")
      expect(rendered).to have_css("dt", text: 'Artworks:')
      expect(rendered).to have_selector("img[src='#{proof.artworks.first.preview.file.url(:thumb)}']")
      expect(rendered).to have_selector("a[href='#{proof.artworks.first.artwork.file.url}']")
      expect(rendered).to have_css("dt", text: 'Mockups:')
      expect(rendered).to have_selector("a[href='#{edit_order_proof_path(order, proof)}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(order, proof)}']")
      expect(rendered).to have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'false')}']")
      expect(rendered).to_not have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'true')}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Approved', order_id: order.id)}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Rejected', order_id: order.id)}']")
    end
  end

  context 'proof status is Emailed Customer' do
    let!(:proof){ create(:valid_proof, status: 'Emailed Customer') }
    let!(:order){ Order.find(proof.order_id) }
    it 'displays all of the info for a proof, edit, destroy, email customer, remind customer, approve, and reject buttons, all in a unique div' do
      expect(rendered).to have_selector("div#proof-#{proof.id}")
      expect(rendered).to have_selector("div.proof-notes")
      expect(rendered).to have_selector("h4.proof-title")
      expect(rendered).to have_css("dt", text: 'Proof Status:')
      expect(rendered).to have_css("dd", text: "#{proof.status}")
      expect(rendered).to have_css("dt", text: 'Approve By:')
      expect(rendered).to have_css("dd", text: "#{proof.approve_by.strftime('%b %d, %Y, %I:%M %p')}")
      expect(rendered).to have_css("dt", text: 'Artworks:')
      expect(rendered).to have_selector("img[src='#{proof.artworks.first.preview.file.url(:thumb)}']")
      expect(rendered).to have_selector("a[href='#{proof.artworks.first.artwork.file.url}']")
      expect(rendered).to have_css("dt", text: 'Mockups:')
      expect(rendered).to have_selector("a[href='#{edit_order_proof_path(order, proof)}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(order, proof)}']")
      expect(rendered).to have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'false')}']")
      expect(rendered).to have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'true')}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Approved', order_id: order.id)}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Rejected', order_id: order.id)}']")
    end
  end

  context 'proof status is Approved' do
    let!(:proof){ create(:valid_proof, status: 'Approved', approved_at: Time.now) }
    let!(:order){ Order.find(proof.order_id) }
    it 'displays all of the info for a proof, edit and destroy buttons, all in a unique div' do
      expect(rendered).to have_selector("div#proof-#{proof.id}")
      expect(rendered).to have_selector("div.proof-notes")
      expect(rendered).to have_selector("h4.proof-title")
      expect(rendered).to have_css("dt", text: 'Proof Status:')
      expect(rendered).to have_css("dd", text: "#{proof.status}")
      expect(rendered).to have_css("dt", text: 'Approve By:')
      expect(rendered).to have_css("dd", text: "#{proof.approve_by.strftime('%b %d, %Y, %I:%M %p')}")
      expect(rendered).to have_css("dt", text: 'Artworks:')
      expect(rendered).to have_selector("img[src='#{proof.artworks.first.preview.file.url(:thumb)}']")
      expect(rendered).to have_selector("a[href='#{proof.artworks.first.artwork.file.url}']")
      expect(rendered).to have_css("dt", text: 'Mockups:')
      expect(rendered).to have_selector("a[href='#{edit_order_proof_path(order, proof)}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(order, proof)}']")
      expect(rendered).to_not have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'false')}']")
      expect(rendered).to_not have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'true')}']")
      expect(rendered).to_not have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Approved', order_id: order.id)}']")
      expect(rendered).to_not have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Rejected', order_id: order.id)}']")
    end
  end

  context 'proof status is Rejected' do
    let!(:proof){ create(:valid_proof, status: 'Rejected') }
    let!(:order){ Order.find(proof.order_id) }
    it 'displays all of the info for a proof, edit and destroy buttons, all in a unique div' do
      expect(rendered).to have_selector("div#proof-#{proof.id}")
      expect(rendered).to have_selector("div.proof-notes")
      expect(rendered).to have_selector("h4.proof-title")
      expect(rendered).to have_css("dt", text: 'Proof Status:')
      expect(rendered).to have_css("dd", text: "#{proof.status}")
      expect(rendered).to have_css("dt", text: 'Approve By:')
      expect(rendered).to have_css("dd", text: "#{proof.approve_by.strftime('%b %d, %Y, %I:%M %p')}")
      expect(rendered).to have_css("dt", text: 'Artworks:')
      expect(rendered).to have_selector("img[src='#{proof.artworks.first.preview.file.url(:thumb)}']")
      expect(rendered).to have_selector("a[href='#{proof.artworks.first.artwork.file.url}']")
      expect(rendered).to have_css("dt", text: 'Mockups:')
      expect(rendered).to have_selector("a[href='#{edit_order_proof_path(order, proof)}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(order, proof)}']")
      expect(rendered).to_not have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'false')}']")
      expect(rendered).to_not have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'true')}']")
      expect(rendered).to_not have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Approved', order_id: order.id)}']")
      expect(rendered).to_not have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Rejected', order_id: order.id)}']")
    end
  end

end