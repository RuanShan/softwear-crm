require 'spec_helper'

describe 'colors/_form.html.erb', color_spec: true do
  before(:each){ render partial: 'colors/form', locals: { color: Color.new}}

  it 'has text_field for name, sku and a submit button' do
    color = Color.new
    f = LancengFormBuilder.dummy_for color
    render partial: 'colors/form', locals: {color: color, f: f}
    within_form_for Color, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_selector('button')
    end
  end
end