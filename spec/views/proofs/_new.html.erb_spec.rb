require 'spec_helper'

describe 'proofs/_new.html.erb', proof_spec: true do
  before(:each) do
    render partial: 'proofs/new', locals: { proof: build_stubbed(:blank_proof), order: build_stubbed(:blank_proof) }
  end

  it 'renders _form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end
end