require 'spec_helper'

describe 'imprintables/show.html.erb', imprintable_spec: true do
  let!(:imprintable){ create(:valid_imprintable) }
  login_user

  it 'has a tabbed display with basic info, size/color availability, imprint details, and supplier information listed' do
    assign(:imprintable, imprintable)
    render file: 'imprintables/show', id: imprintable.to_param
    expect(rendered).to have_selector("#basic_info_#{imprintable.id}")
    expect(rendered).to have_selector("#size_color_availability_#{imprintable.id}")
    expect(rendered).to have_selector("#imprint_details_#{imprintable.id}")
    expect(rendered).to have_selector("#supplier_information_#{imprintable.id}")
  end
end
