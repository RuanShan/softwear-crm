require 'spec_helper'

describe 'imprintables/_basic_info.html.erb', imprintable_spec: true do
  let!(:imprintable) { create(:valid_imprintable) }
  login_user

  it 'should display all of the basic information regarding the imprintable' do
    render partial: 'imprintables/basic_info', locals: { imprintable: imprintable }
    expect(rendered).to have_css('dt', text: 'Material')
    expect(rendered).to have_css('dt', text: 'Weight')
    expect(rendered).to have_css('dt', text: /Colors Offered/)
    expect(rendered).to have_css('dt', text: /Sizes Offered/)
    expect(rendered).to have_css('dt', text: 'Sample Locations')
    expect(rendered).to have_css('dt', text: 'Weight')
    expect(rendered).to have_css('dt', text: 'Max Imprint Height')
    expect(rendered).to have_css('dt', text: 'Max Imprint Width')
    expect(rendered).to have_css('dt', text: 'Tags')
    expect(rendered).to have_css('dt', text: 'Description')
    expect(rendered).to have_css('dt', text: 'Coordinates')
  end

  context 'there are more colors and sizes than there are associated with the imprintable' do
    let!(:color_one) { create(:valid_color) }
    let!(:color_two) { create(:valid_color) }
    let!(:size_one) { create(:valid_size) }
    let!(:size_two) { create(:valid_size) }
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }
    it 'should display the correct number of colors and sizes' do
      imprintable_variant.imprintable_id = imprintable.id
      imprintable_variant.color_id = color_one.id
      imprintable_variant.size_id = size_one.id
      imprintable_variant.save
      render partial: 'imprintables/basic_info', locals: { imprintable: imprintable }
      expect(rendered).to have_content(color_one.name)
      expect(rendered).to_not have_content(color_two.name)
      expect(rendered).to have_content(size_one.name)
      expect(rendered).to_not have_content(size_two.name)
    end
  end
end
