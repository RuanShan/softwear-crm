require 'spec_helper'

describe 'brands/_form.html.erb', brand_spec: true do
  before(:each){ render partial: 'brands/form', locals: { brand: Brand.new}}

  it 'has text_field for name, sku and a submit button' do
    brand = Brand.new
    f = LancengFormBuilder.dummy_for brand
    render partial: 'brands/form', locals: {brand: brand, f: f}
    within_form_for Brand, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_selector('button')
    end
  end
end