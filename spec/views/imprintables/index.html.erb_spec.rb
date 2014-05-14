require 'spec_helper'

describe 'imprintables/index.html.erb' do

  before(:each) do
    assign(:imprintables, [create(:valid_imprintable)])
    render
  end

  it 'has table with name, catalog number, description columns' do
    expect(rendered).to have_css('th', text: 'Name')
    expect(rendered).to have_css('th', text: 'Catalog Number')
    expect(rendered).to have_css('th', text: 'Description')
  end

  context 'there is an imprintable' do
    let(:imprintable) {create(:valid_imprintable) }

    it 'displays the name, catalog number, and description of that imprintable' do
      expect(rendered).to have_css('td', text: imprintable.name)
      expect(rendered).to have_css('td', text: imprintable.catalog_number)
      expect(rendered).to have_css('td', text: imprintable.description)
    end
  end
end