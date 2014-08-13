require 'spec_helper'

describe 'imprintables/_imprint_details.html.erb', imprintable_spec: true do
  before(:each) do
    render partial: 'imprintables/imprint_details',
           locals: { imprintable: build_stubbed(:valid_imprintable) }
  end

  it 'display appropriate information regarding the imprint' do
    expect(rendered).to have_css('dt', text: 'Sizing Category')
    expect(rendered).to have_css('dt', text: 'Compatible Imprint Methods')
    expect(rendered).to have_css('dt', text: 'Flashable?')
    expect(rendered).to have_css('dt', text: 'Polyester?')
    expect(rendered).to have_css('dt', text: 'Special Considerations')
    expect(rendered).to have_css('dt', text: 'Proofing Template Name')
  end
end
