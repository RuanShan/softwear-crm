require 'spec_helper'

describe 'sizes/_form.html.erb', size_spec: true do
  it 'has text_field for name, catalog_no, description, sku and a submit button' do
    size = Size.new
    f = LancengFormBuilder.dummy_for size
    render partial: 'sizes/form', locals: { size: size, f: f }
    within_form_for Size, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_selector('button')
    end
  end
end
