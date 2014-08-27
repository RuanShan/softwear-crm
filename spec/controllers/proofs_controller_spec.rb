require 'spec_helper'
include ApplicationHelper

describe ProofsController, js: true, proofs_spec: true do
  let!(:proof) { create(:valid_proof) }
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'email_customer' do
    context 'GET request' do
      it 'assigns @variable_hash and renders email_customer.js.erb' do
        get :email_customer, id: proof.id, order_id: proof.order_id,
                             reminder: 'false', format: 'js'
        expect(response).to render_template('email_customer')
        expect(assigns(:variable_hash)).to eq({
                                                order: Order.find(proof.order_id),
                                                proof: proof,
                                                reminder: false
                                              })
      end
    end

    context 'POST request' do
      context 'reminder is false' do
        it 'sends approval email, and changes status to Emailed Customer' do
          expect(ProofMailer).to receive(:proof_approval_email).with(an_instance_of(Hash)).and_return(double('ProofMailer', deliver: true))
          post :email_customer, id: proof.id, order_id: proof.order_id,
                                reminder: 'false', format: 'js'
          expect(Proof.find(proof.id).status).to eq('Emailed Customer')
        end
      end

      context 'reminder is true' do
        let!(:order) { Order.find(proof.order_id) }
        it 'sends reminder email and does not change the proof status' do
          expect(ProofMailer).to receive(:proof_reminder_email).with(an_instance_of(Hash)).and_return(double('ProofMailer', deliver: true))
          post :email_customer, id: proof.id, order_id: proof.order_id,
                                reminder: 'true', format: 'js'
          expect(Proof.find(proof.id).status).to eq(proof.status)
        end
      end
    end
  end
end