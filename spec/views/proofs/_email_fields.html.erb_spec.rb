require 'spec_helper'

describe 'proofs/_email_fields.html.erb', proof_spec: true do
  let!(:proof){ create(:valid_proof) }
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  it 'renders editable fields for the email subject and email body as well as a submit button, regardless of the reminder value' do
    render partial: 'proofs/email_fields', locals: {order: Order.find(proof.order_id), proof: proof, reminder: true}
    expect(rendered).to have_selector("input#email_subject")
    expect(rendered).to have_selector("input#email_body")
    expect(rendered).to have_selector("input[type='submit']")
    render partial: 'proofs/email_fields', locals: {order: Order.find(proof.order_id), proof: proof, reminder: false}
    expect(rendered).to have_selector("input#email_subject")
    expect(rendered).to have_selector("input#email_body")
    expect(rendered).to have_selector("input[type='submit']")
  end

end