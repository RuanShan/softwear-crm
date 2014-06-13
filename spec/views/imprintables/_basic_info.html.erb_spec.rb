require 'spec_helper'

describe 'imprintables/_basic_info.html.erb', imprintable_spec: true do
  login_user

  it 'should display all of the basic information regarding the imprintable' do
    imprintable = create(:valid_imprintable)
    render partial: 'imprintables/basic_info', locals: { imprintable: imprintable }
    expect(rendered).to have_css('dt', text: 'Material')
    expect(rendered).to have_css('dt', text: /Colors Offered/)
    expect(rendered).to have_css('dt', text: /Sizes Offered/)
    expect(rendered).to have_css('dt', text: 'Sample Locations')
    expect(rendered).to have_css('dt', text: 'Tags')
    expect(rendered).to have_css('dt', text: 'Description')
    expect(rendered).to have_css('dt', text: 'Coordinates')
  end
end
