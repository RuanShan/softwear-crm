require 'spec_helper'
include ApplicationHelper

describe ProofsController, js: true, proofs_spec: true do

  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'GET new' do
    let!(:proof){ create(:valid_proof) }
    it 'renders new.js.erb' do
      get :new, id: proof.id, order_id: proof.order_id, format: 'js'
      expect(response).to render_template('new')
    end
  end

  describe 'GET edit' do
    let!(:proof){ create(:valid_proof) }
    it 'renders edit.js.erb' do
      get :edit, id: proof.id, order_id: proof.order_id, format: 'js'
      expect(response).to render_template('edit')
    end
  end

  describe 'DELETE destroy' do
    let!(:proof){ create(:valid_proof) }
    it 'renders destroy.js.erb' do
      delete :destroy, id: proof.id, order_id: proof.order_id, format: 'js'
      expect(response).to render_template('destroy')
    end
  end

  describe 'POST create' do
    let!(:proof){ create(:valid_proof) }
    context 'with valid input' do
      it 'renders create.js.erb and creates proof' do
        post :create, proof: attributes_for(:valid_proof), order_id: create(:order).id, format: 'js'
        expect(response).to render_template('create')
        expect(Proof.where(id: proof.id)).to exist
      end
    end
  end

  describe 'PUT update' do
    let!(:proof){ create(:valid_proof) }
    context 'with valid input' do
      it 'renders update.js.erb' do
        put :update, id: proof.id, proof: attributes_for(:valid_proof), order_id: proof.order_id, format: 'js'
        expect(response).to render_template('update')
        expect(Artwork.where(id: proof.id)).to exist
      end
    end
  end

  describe 'email_customer' do
    context 'GET request' do
      let!(:proof){ create(:valid_proof) }
      it 'assigns proof, order, and reminder as well as rendering email_customer.js.erb, regardless of reminder value' do
        get :email_customer, id: proof.id, order_id: proof.order_id, reminder: 'false', format: 'js'
        expect(response).to render_template('email_customer')
        expect(assigns(:proof)).to eq(proof)
        expect(assigns(:order).id).to eq(proof.order_id)
        expect(assigns(:reminder)).to eq(false)
      end
    end
    context 'POST request' do
      context 'reminder is false' do
        let!(:proof){ create(:valid_proof) }
        it 'assigns proof, order, and reminder, sends approval email, and changes status to Emailed Customer' do
          expect(ProofMailer).to receive(:proof_approval_email).with(an_instance_of(Proof), an_instance_of(Order), nil, nil).and_return( double('ProofMailer', deliver: true) )
          post :email_customer, id: proof.id, order_id: proof.order_id, reminder: 'false', format: 'js'
          expect(assigns(:proof)).to eq(proof)
          expect(assigns(:order).id).to eq(proof.order_id)
          expect(assigns(:reminder)).to eq(false)
          expect(assigns(:proof).status).to_not eq(proof.status)
          expect(assigns(:proof).status).to eq('Emailed Customer')
        end
      end

      context 'reminder is true' do
        let!(:proof){ create(:valid_proof) }
        let!(:order){ Order.find(proof.order_id) }
        it 'assigns proof, order, and reminder, sends reminder email, and doesnt change the proof status' do
          expect(ProofMailer).to receive(:proof_reminder_email).with(an_instance_of(Proof), an_instance_of(Order), I18n.t('proof_reminder_body_html', firstname: order.firstname, lastname: order.lastname), I18n.t('proof_reminder_subject', id: order.id)).and_return( double('ProofMailer', deliver: true) )
          post :email_customer, id: proof.id, order_id: proof.order_id, reminder: 'true', format: 'js'
          expect(assigns(:proof)).to eq(proof)
          expect(assigns(:order).id).to eq(proof.order_id)
          expect(assigns(:reminder)).to eq(true)
          expect(assigns(:proof).status).to eq(proof.status)
        end
      end
    end
  end
end