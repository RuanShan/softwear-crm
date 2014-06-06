require 'spec_helper'

describe 'imprint_methods/_ink_color_fields.html.erb' do
  let(:imprint_method){ create(:valid_imprint_method) }

  it 'has remove button' do
    f =
    render partial: 'imprint_methods/ink_color_fields', f: f
    expect(rendered).to have_selector("button")
  end
end