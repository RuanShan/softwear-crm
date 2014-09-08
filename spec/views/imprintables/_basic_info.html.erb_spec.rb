require 'spec_helper'

describe 'imprintables/_basic_info.html.erb', imprintable_spec: true do
  login_user

  let!(:imprintable) { build_stubbed(:valid_imprintable) }
  let!(:color) { build_stubbed(:valid_color) }
  let!(:size) { build_stubbed(:valid_size) }

  before(:each) do
    allow(imprintable).to receive(:colors).and_return([color])
    allow(imprintable).to receive(:sizes).and_return([size])

    allow(imprintable).to receive_message_chain(:sample_locations, :map, :join).and_return('Front, Back')
    allow(imprintable).to receive_message_chain(:tag_list, :join).and_return('Soft, Comfy')
    allow(imprintable).to receive_message_chain(:coordinates, :map, :join).and_return('cord1, cord2')
    allow(imprintable).to receive_message_chain(:imprintable_categories, :map, :join).and_return('cat1, cat2')
    allow(imprintable).to receive(:common_name).and_return('Common Name!')

    render partial: 'imprintables/basic_info', locals: { imprintable: imprintable }
  end

  it 'displays all the list headers' do
    expect(rendered).to have_css('dt', text: 'Material')
    expect(rendered).to have_css('dt', text: 'Weight')
    expect(rendered).to have_css('dt', text: 'Max Imprint Width')
    expect(rendered).to have_css('dt', text: 'Max Imprint Height')
    expect(rendered).to have_css('dt', text: /Colors Offered/)
    expect(rendered).to have_css('dt', text: /Sizes Offered/)
    expect(rendered).to have_css('dt', text: 'Sample Locations')
    expect(rendered).to have_css('dt', text: 'Tags')
    expect(rendered).to have_css('dt', text: 'Description')
    expect(rendered).to have_css('dt', text: 'Coordinates')
    expect(rendered).to have_css('dt', text: 'Categories')
    expect(rendered).to have_css('dt', text: 'Common Name')
  end

  it 'displays all the imprintable\'s information' do
    expect(rendered).to have_css('dd', text: imprintable.material)
    expect(rendered).to have_css('dd', text: imprintable.weight)
    expect(rendered).to have_css('dd', text: imprintable.max_imprint_width)
    expect(rendered).to have_css('dd', text: imprintable.max_imprint_height)
    expect(rendered).to have_css('dd', text: color.name)
    expect(rendered).to have_css('dd', text: size.name)
    expect(rendered).to have_css('dd', text: 'Front, Back')
    expect(rendered).to have_css('dd', text: 'Soft, Comfy')
    expect(rendered).to have_css('dd', text: imprintable.description)
    expect(rendered).to have_css('dd', text: 'cord1, cord2')
    expect(rendered).to have_css('dd', text: 'cat1, cat2')
    expect(rendered).to have_css('dd', text: 'Common Name!')
  end
end
