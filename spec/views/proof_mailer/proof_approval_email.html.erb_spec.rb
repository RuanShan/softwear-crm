require 'spec_helper'

describe 'proof_mailer/proof_approval_email.html.erb', proof_spec: true do
  context 'body exists' do
    let!(:body) { 'body' }
    it 'renders the body of the email' do
      assign(:body, body)
      render
      expect(rendered).to have_text(body)
    end
  end

  context 'body doesnt exist' do
    let!(:body) { 'body' }
    it 'renders an email with no body' do
      render
      expect(rendered).to_not have_text(body)
    end
  end
end