require 'spec_helper'

describe 'colors/_form.html.erb', color_spec: true do
  let!(:color){ build_stubbed(:blank_color) }

  before(:each) do
    form_for(color){|f| @f = f }
    render partial: 'colors/form', locals: { color: Color.new, f: @f }
  end

  it 'has fields for name, sku, retail and a submit button' do
    within_form_for Color, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_selector('button')
    end
  end
end
