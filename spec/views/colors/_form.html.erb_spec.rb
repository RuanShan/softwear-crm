require 'spec_helper'

describe 'colors/_form.html.erb', color_spec: true do
  let!(:color){ build_stubbed(:blank_color) }

  before(:each) do
    form_for(color){|f| @f = f }
    render partial: 'colors/form', locals: { color: Color.new, f: @f }
  end

  it 'has text_field for name' do
    expect_field_within_form(Color, :name)
  end

  it 'has field for sku' do
    expect_field_within_form(Color, :sku)
  end

  it 'has field for retail' do
    expect_field_within_form(Color, :sku)
  end

  it 'has a submit button' do
    expect(rendered).to have_selector('button')
  end
end
