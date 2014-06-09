require 'spec_helper'

describe 'imprint_methods/_print_location_fields.html.erb' do
  let(:imprint_method){ create(:valid_imprint_method_with_color_and_location) }

  it 'has remove button' do
    form_for(imprint_method){ |f| f.fields_for(:ink_colors){ |ff| @f = ff } }
    render partial: 'imprint_methods/ink_color_fields', locals: {f: @f}
    expect(rendered).to have_selector("input[id^='imprint_method_ink_colors_attributes_'][id$='_name']")
    expect(rendered).to have_selector("a[class='btn btn-info remove_fields pull-right']")
    expect(rendered).to have_selector("div[class='removeable']")
  end
end