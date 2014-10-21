require 'spec_helper'

describe 'imprintables/retail_upcharge_fields.html.erb', story_185: true, imprintable_spec: true do

  let(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    f = test_form_for imprintable, builder: LancengFormBuilder
    render 'retail_upcharge_fields', f: f
  end

  it 'has fields for base_upcharge + each size xxl and above' do
    expect(rendered).to have_css('input#imprintable_base_upcharge')
    expect(rendered).to have_css('input#imprintable_xxl_upcharge')
    expect(rendered).to have_css('input#imprintable_xxxl_upcharge')
    expect(rendered).to have_css('input#imprintable_xxxxl_upcharge')
    expect(rendered).to have_css('input#imprintable_xxxxxl_upcharge')
    expect(rendered).to have_css('input#imprintable_xxxxxxl_upcharge')
  end
end
