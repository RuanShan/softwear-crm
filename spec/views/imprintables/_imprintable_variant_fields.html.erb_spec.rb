require 'spec_helper'

describe 'imprintables/imprintable_variant_fields.html.erb', imprintable_spec: true do

  let(:imprintable_variant) { build_stubbed(:valid_imprintable_variant) }


  before(:each) do
    expect(imprintable_variant).to receive_message_chain(:color, :name).and_return('Color')
    expect(imprintable_variant).to receive_message_chain(:imprintable, :name).and_return('Imp')

    f = test_form_for imprintable_variant, builder: LancengFormBuilder
    render 'imprintables/imprintable_variant_fields', { f: f }
  end

  it 'has a field for weight' do
    expect(rendered).to have_css('div.col-sm-1.quote-variant-weight input.form-control')
  end
end
