require 'spec_helper'

describe 'proofs/_proof.html.erb', proof_spec: true do
  let!(:order) { build_stubbed(:blank_order) }

  before(:each) do
    render partial: 'proofs/proof', locals: { order: order, proof: proof }
  end

  context 'given a single proof' do
    let(:proof) { build_stubbed(:blank_proof, artworks: [build_stubbed(:blank_artwork)]) }

    it 'displays all of the info for a proof, edit, destroy, email customer, approve, and reject buttons, all in a unique div' do
      expect(rendered).to have_selector("div#proof-#{proof.id}")
      expect(rendered).to have_selector('div.proof-notes')
      expect(rendered).to have_selector('h4.proof-title')
      expect(rendered).to have_css('dt', text: 'Proof Status:')
      expect(rendered).to have_css('dd', text: "#{proof.status}")
      expect(rendered).to have_css('dt', text: 'Approve By:')
      expect(rendered).to have_css('dd', text: "#{display_time(proof.approve_by)}")
      expect(rendered).to have_css('dt', text: 'Artworks:')
      expect(rendered).to have_selector("img[src='#{proof.artworks.first.preview.file.url(:thumb)}']")
      expect(rendered).to have_selector("a[href='#{proof.artworks.first.artwork.file.url}']")
      expect(rendered).to have_css('dt', text: 'Mockups:')
      expect(rendered).to have_selector("a[href='#{edit_order_proof_path(order, proof)}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(order, proof)}']")
      expect(rendered).to have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'false')}']")
      expect(rendered).to_not have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'true')}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Approved', order_id: order.id)}']")
      expect(rendered).to have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Rejected', order_id: order.id)}']")
    end

    context 'proof status is Emailed Customer' do
      let(:proof) { build_stubbed(:blank_proof, status: 'Emailed Customer') }

      it 'adds a remind customer button' do
        expect(rendered).to have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'true')}']")
      end
    end

    context 'proof status is Approved' do
      let(:proof) { build_stubbed(:blank_proof, status: 'Approved', approved_at: Time.now) }

      it 'removes the email buttons and approve/reject buttons' do
        expect(rendered).to_not have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'false')}']")
        expect(rendered).to_not have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'true')}']")
        expect(rendered).to_not have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Approved', order_id: order.id)}']")
        expect(rendered).to_not have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Rejected', order_id: order.id)}']")
      end
    end

    context 'proof status is Rejected' do
      let(:proof) { build_stubbed(:blank_proof, status: 'Rejected') }

      it 'removes the email buttons and approve/reject buttons' do
        expect(rendered).to_not have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'false')}']")
        expect(rendered).to_not have_selector("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'true')}']")
        expect(rendered).to_not have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Approved', order_id: order.id)}']")
        expect(rendered).to_not have_selector("a[href='#{order_proof_path(id: proof.id, status: 'Rejected', order_id: order.id)}']")
      end
    end
  end
end