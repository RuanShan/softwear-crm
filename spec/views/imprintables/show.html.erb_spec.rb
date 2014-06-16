require 'spec_helper'

describe 'imprintables/show.html.erb', imprintable_spec: true do
  let!(:imprintable){ create(:valid_imprintable) }
  login_user

  it 'has a tabbed display with basic info, size/color availability, imprint details, and supplier information listed' do
    assign(:imprintable, imprintable)
    render file: 'imprintables/show', id: imprintable.to_param
    expect(rendered).to have_selector("#basic_info")
    expect(rendered).to have_selector("#size_color_availability")
    expect(rendered).to have_selector("#imprint_details")
    expect(rendered).to have_selector("#supplier_information")
  end
end
