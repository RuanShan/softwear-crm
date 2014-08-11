require 'spec_helper'

describe 'proofs/_mockup_fields.html.erb', proof_spec: true do
  let!(:proof){ create(:valid_proof) }
  let!(:order){ Order.find(proof.order_id) }
  let!(:mockups){ create(:valid_asset) }
  context 'no mockups exists yet, i.e. new form' do
    it 'displays the correct form fields for mockups' do
      form_for(proof, url: order_proofs_path(order, proof)){|f| f.fields_for(Asset.new, multipart: true){|ff| @f = ff } }
      render partial: 'proofs/mockup_fields', locals: {object: Asset.new, f: @f}
      within_form_for Asset do
        expect(rendered).to have_selector("input[id$='file']")
        expect(rendered).to have_selector("textarea[id$='description']")
        expect(rendered).to have_selector("a.js-remove-fields")
      end
    end
  end

  context 'mockups exists already' do
    it 'displays the name of the file and an editable description field' do
      form_for(proof, url: order_proofs_path(order, proof)){|f| f.fields_for(mockups, multipart: true){|ff| @f = ff } }
      render partial: 'proofs/mockup_fields', locals: {object: mockups, f: @f}
      within_form_for Asset do
        expect(rendered).to have_css("div", text: "#{mockups.file_file_name}")
        expect(rendered).to have_selector("textarea[id$='description']", text: "#{mockups.description}")
      end
    end
  end

end