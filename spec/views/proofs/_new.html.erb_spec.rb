require 'spec_helper'

describe 'proofs/_new.html.erb', proof_spec: true do

  before(:each) do
    render partial: 'proofs/new', locals: {proof: Proof.new, order: create(:order)}
  end

  it 'renders _form.html.erb' do
    expect(rendered).to render_template(partial: '_form')
  end

end