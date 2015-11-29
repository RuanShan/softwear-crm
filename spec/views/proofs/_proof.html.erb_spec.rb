require 'spec_helper'

describe 'proofs/_proof.html.erb', proof_spec: true do
  let!(:order) { build_stubbed(:blank_order) }
  let!(:artwork) { create(:valid_artwork) }
  let(:proof) { create(:valid_proof, mockups: [create(:valid_asset)], artworks: [ artwork ]) }
  let(:mockup) { proof.mockups.first }

  context 'regardless of what transitions a proof can make' do
    before { render 'proofs/proof', { order: order, proof: proof } }

    it 'displays all of the info for a proof and an edit link', wip: true do
      expect(rendered).to have_selector("div#proof-#{proof.id}")
      expect(rendered).to have_css('h4', text: "Proof ##{proof.id}")
      expect(rendered).to have_css('h4', text: "Mockups")
      expect(rendered).to have_css('h4', text: "Artworks")
      expect(rendered).to have_css('dt', text: 'Proof State:')
      expect(rendered).to have_css('dd', text: proof.human_state_name)
      expect(rendered).to have_css('dt', text: 'Approve By:')
      expect(rendered).to have_css('dd', text: display_time(proof.approve_by))
      expect(rendered).to have_css("[data-mockup-id='#{proof.mockups.first.id}']")
      expect(rendered).to have_css("[data-artwork-id='#{proof.artworks.first.id}']")
      expect(rendered).to have_link("Edit")
    end
  end

  context 'when it can transition to a given state' do
    before do
      allow_any_instance_of(Proof).to receive(:can_ready?) { true }
      allow_any_instance_of(Proof).to receive(:can_manager_approved?) { true }
      allow_any_instance_of(Proof).to receive(:can_manager_rejected?) { true }
      allow_any_instance_of(Proof).to receive(:can_emailed_customer?) { true }
      allow_any_instance_of(Proof).to receive(:can_customer_approved?) { true }
      allow_any_instance_of(Proof).to receive(:can_customer_rejected?) { true }
      allow_any_instance_of(Proof).to receive(:can_customer_rejected?) { true }
      render 'proofs/proof', { order: order, proof: proof }
    end

    it 'does render the links to transition' do
      expect(rendered).to have_link 'Ready For Manager Approval'
      expect(rendered).to have_link 'Manager Approved'
      expect(rendered).to have_link 'Manager Rejected'
      expect(rendered).to have_link 'Emailed Customer'
      expect(rendered).to have_link 'Customer Approved'
      expect(rendered).to have_link 'Customer Rejected'
    end
  end

  context 'when it cannot transition to a given state' do
    before do
      allow_any_instance_of(Proof).to receive(:can_ready?) { false }
      allow_any_instance_of(Proof).to receive(:can_manager_approved?) { false }
      allow_any_instance_of(Proof).to receive(:can_manager_rejected?) { false }
      allow_any_instance_of(Proof).to receive(:can_emailed_customer?) { false }
      allow_any_instance_of(Proof).to receive(:can_customer_approved?) { false }
      allow_any_instance_of(Proof).to receive(:can_customer_rejected?) { false }
      render 'proofs/proof', { order: order, proof: proof }
    end

    it 'does render the links to transition' do
      expect(rendered).to_not have_link 'Ready For Manager Approval'
      expect(rendered).to_not have_link 'Manager Approved'
      expect(rendered).to_not have_link 'Manager Rejected'
      expect(rendered).to_not have_link 'Emailed Customer'
      expect(rendered).to_not have_link 'Customer Approved'
      expect(rendered).to_not have_link 'Customer Rejected'
    end
  end
end
