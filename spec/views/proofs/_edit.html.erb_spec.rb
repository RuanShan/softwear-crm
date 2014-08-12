require 'spec_helper'

describe 'proofs/_edit.html.erb', proof_spec: true do
  let!(:proof){ build_stubbed(:blank_proof) }
  let!(:order){ build_stubbed(:blank_order) }

  before(:each) do
    render partial: 'proofs/edit', locals: { order: order, proof: proof }
  end

  it 'renders _form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end
end