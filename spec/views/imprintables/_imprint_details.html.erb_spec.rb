require 'spec_helper'

describe 'imprintables/_imprint_details.html.erb', imprintable_spec: true do
  login_user

  it 'display appropriate information regarding the imprint' do
    imprintable = create :valid_imprintable
    render partial: 'imprintables/imprint_details', locals: { imprintable: imprintable }
    expect(rendered).to have_css('dt', text: 'Sizing Category')
    expect(rendered).to have_css('dt', text: 'Compatible Imprint Methods')
    expect(rendered).to have_css('dt', text: 'Flashable?')
    expect(rendered).to have_css('dt', text: 'Polyester?')
    expect(rendered).to have_css('dt', text: 'Special Considerations')
    expect(rendered).to have_css('dt', text: 'Proofing Template Name')
  end
end
