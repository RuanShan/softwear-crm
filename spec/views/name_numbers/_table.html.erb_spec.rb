require 'spec_helper'

describe "name_numbers/_table", type: :view do

  let(:order) { build_stubbed(:order) }
  let(:name_number) { create(:name_number) }

  before(:each) do
    allow_any_instance_of(Order).to receive(:name_and_numbers).and_return([ name_number ] )
    render 'name_numbers/table', order: order, show_breakdown: true
  end

  it 'has columns for job, imprint, imprintable, name, and number' do
   expect(rendered).to have_css :th, text: 'Job'
   expect(rendered).to have_css :th, text: 'Imprint'
   expect(rendered).to have_css :th, text: 'Imprintable'
   expect(rendered).to have_css :th, text: 'Name'
   expect(rendered).to have_css :th, text: 'Number'
  end

  it 'for the imprint column, displays imprint name, name format, and number format' do
    expect(rendered).to have_css('td.imprint-name-and-format', text: name_number.imprint.name)
    expect(rendered).to have_css('td.imprint-name-and-format', text: name_number.imprint.name_format)
    expect(rendered).to have_css('td.imprint-name-and-format', text: name_number.imprint.number_format)
  end

end
