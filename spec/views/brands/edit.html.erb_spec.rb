require 'spec_helper'

describe 'brands/edit.html.erb' do
  let(:brand){ create(:valid_brand) }

  it 'has a form to create a new mockup group' do
    assign(:brand, brand)
    render file: 'brands/edit', id: brand.to_param
    expect(rendered).to have_selector("form[action='#{brand_path(brand)}'][method='post']")
  end
end