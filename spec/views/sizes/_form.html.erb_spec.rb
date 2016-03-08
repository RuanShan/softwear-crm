require 'spec_helper'

describe 'sizes/_form.html.erb', size_spec: true do
  before(:each) do
    size = build_stubbed(:valid_size)
    f = test_form_for size, builder: LancengFormBuilder
    render partial: 'sizes/form', locals: { size: size, f: f }
  end

  it 'has text_field for name, catalog_no, description, sku and a submit button' do
    within_form_for Size, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_field_for :upcharge_group
      expect(rendered).to have_selector('button')
    end
  end
end
