require 'spec_helper'

describe 'proofs/email_customer.html.erb', proof_spec: true, story_207: true do
  let!(:proof) { create(:valid_proof) }
  let!(:order) { create(:order) }

  before(:each) do
    render file: 'proofs/email_customer',
           locals: { proof: proof, order: order, reminder: false }
  end

  it 'should have subject, body, and submit button' do
    expect(rendered).to have_css("input#email_subject[value='Your Proof from the Ann Arbor T-shirt Company Order ##{order.id} is awaiting your approval']")
    expect(rendered).to have_css("input#email_body")
    expect(rendered).to have_css("input[type='submit'][value='Send Email']")
  end
end