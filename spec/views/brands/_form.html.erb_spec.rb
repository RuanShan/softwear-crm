require 'spec_helper'

describe 'brands/_form.html.erb', brand_spec: true do

  before(:each) do
    brand = build_stubbed(:valid_brand)
    f = LancengFormBuilder.dummy_for brand
    render partial: 'brands/form', locals: { brand: brand, f: f }
  end

  it 'has field for name' do
    expect_field_within_form(Brand, :name)
  end

  it 'has field for sku' do
    expect_field_within_form(Brand, :sku)
  end

  it 'has field for retail' do
    expect_field_within_form(Brand, :retail)
  end

  it 'has a submit button' do
    within_form_for Brand, noscope: true do
      expect(rendered).to have_selector('button')
    end
  end
end
