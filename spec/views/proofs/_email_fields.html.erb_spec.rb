require 'spec_helper'

describe 'proofs/_email_fields.html.erb', proof_spec: true do
  let!(:proof) { build_stubbed(:blank_proof, approve_by: Time.zone.now) }
  let!(:order) { build_stubbed(:blank_order) }

  it 'renders editable fields for the email subject and email body as well as a submit button, regardless of the reminder value' do
    render partial: 'proofs/email_fields', locals: { order: order, proof: proof, reminder: true }
    expect(rendered).to have_selector('input#email_subject')
    expect(rendered).to have_selector('input#email_body')
    expect(rendered).to have_selector("input[type='submit']")

    render partial: 'proofs/email_fields', locals: { order: order, proof: proof, reminder: false }
    expect(rendered).to have_selector('input#email_subject')
    expect(rendered).to have_selector('input#email_body')
    expect(rendered).to have_selector("input[type='submit']")
  end
end