require 'spec_helper'

describe ArtistMailer do

  describe 'proof_approval_email' do
    let!(:proof) { create(:valid_proof) }
    let!(:order) { proof.order }
    subject = 'Subject'
    body = 'Body'
    let!(:mailer) { ProofMailer.proof_approval_email({ body: body,
                                                       subject: subject,
                                                       order: order,
                                                       proof: proof,
                                                       reminder: false }) }

    it 'renders the subject' do
      expect(mailer.subject).to eql(subject)
    end

    it 'renders the receiver email' do
      expect(mailer.to).to eql([order.email])
    end

    it 'renders the sender email' do
      expect(mailer.from).to eql(['noreply@softwearcrm.com'])
    end

    it 'assigns @salesperson' do
      expect(mailer.body.encoded).to match(body)
    end

    it 'assigns @artwork_request' do
      expect(mailer.body.encoded).to match(proof.artworks.first.preview.file_file_name)
    end
  end

  describe 'proof_reminder_email' do
    let!(:proof) { create(:valid_proof) }
    let!(:order) { proof.order }
    subject = 'Subject'
    body = 'Body'
    let!(:mailer) { ProofMailer.proof_reminder_email({ body: body,
                                                       subject: subject,
                                                       order: order,
                                                       proof: proof,
                                                       reminder: true }) }

    it 'renders the subject' do
      expect(mailer.subject).to eql(subject)
    end

    it 'renders the receiver email' do
      expect(mailer.to).to eql([order.email])
    end

    it 'renders the sender email' do
      expect(mailer.from).to eql(['noreply@softwearcrm.com'])
    end

    it 'assigns @salesperson' do
      expect(mailer.body.encoded).to match(body)
    end

    it 'assigns @artwork_request' do
      expect(mailer.body.encoded).to_not match(proof.artworks.first.preview.file_file_name)
    end
  end
end
