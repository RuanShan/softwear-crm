require 'spec_helper'

describe 'proofs/_edit.html.erb', proof_spec: true do
  let!(:proof){ create(:valid_proof) }
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  before(:each) do
    render partial: 'proofs/edit', locals: {proof: proof, order: Order.find(proof.order_id)}
  end

  it 'renders _form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end

end