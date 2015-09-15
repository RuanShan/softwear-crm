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
  end
end
