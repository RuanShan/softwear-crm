require 'spec_helper'

describe 'imprintables/retail_upcharge_fields.html.erb', story_185: true, imprintable_spec: true do

  let(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    f = test_form_for imprintable, builder: LancengFormBuilder
    render 'retail_upcharge_fields', f: f
  end

  it 'has fields each size xxl and above' do
    expect(rendered).to have_css('input#xxl_upcharge')
    expect(rendered).to have_css('input#xxxl_upcharge')
    expect(rendered).to have_css('input#xxxxl_upcharge')
    expect(rendered).to have_css('input#xxxxxl_upcharge')
    expect(rendered).to have_css('input#xxxxxxl_upcharge')
  end
end
