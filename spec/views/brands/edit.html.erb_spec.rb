require 'spec_helper'

describe 'brands/edit.html.erb', brand_spec: true do
  let(:brand) { build_stubbed(:valid_brand) }

  before(:each) do
    assign(:brand, brand)
    render file: 'brands/edit', id: brand.to_param
  end

  it 'has a form to create a new mockup group' do
    expect(rendered).to have_selector("form[action='#{brand_path(brand)}'][method='post']")
  end
end
