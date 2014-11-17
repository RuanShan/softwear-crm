require 'spec_helper'
include ApplicationHelper

describe ProofsController, js: true, proofs_spec: true do
  let!(:proof) { create(:valid_proof) }
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'email_customer' do
    context 'GET request' do
      it 'assigns renders email_customer.html.erb', story_207: true do
        get :email_customer, id: proof.id, order_id: proof.order_id,
                             reminder: 'false'
        expect(response).to render_template('email_customer')
      end
    end

    context 'POST request' do
      context 'reminder is false' do
        it 'sends approval email, and changes status to Emailed Customer' do
          expect{ ProofMailer.delay.proof_approval_email(instance_of(Hash)) }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
          expect{ (post :email_customer, id: proof.id, order_id: proof.order_id,
                        reminder: 'false') }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
          expect(Proof.find(proof.id).status).to eq('Emailed Customer')
        end
      end

      context 'reminder is true' do
        let!(:order) { Order.find(proof.order_id) }
        it 'sends reminder email and does not change the proof status' do
          expect{ ProofMailer.delay.proof_reminder_email(instance_of(Hash)) }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
          expect{ (post :email_customer, id: proof.id, order_id: proof.order_id,
                        reminder: 'true') }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
          expect(Proof.find(proof.id).status).to eq(proof.status)
        end
      end
    end
  end
end