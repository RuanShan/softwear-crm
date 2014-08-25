require 'spec_helper'

describe 'brands/_form.html.erb', brand_spec: true do

  before(:each) do
    brand = build_stubbed(:valid_brand)
    f = test_form_for brand, builder: LancengFormBuilder
    render partial: 'brands/form', locals: { brand: brand, f: f }
  end

  it 'has field for name, sku, retail and submit' do
    within_form_for Brand, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_selector('button')
    end
  end
end
