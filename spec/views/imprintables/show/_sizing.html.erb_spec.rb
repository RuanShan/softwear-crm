require 'spec_helper'

describe 'imprintables/show/_sizing.html.erb', imprintable_spec: true do
  before(:each) do
    imprintable = build_stubbed(:valid_imprintable)
    size = build_stubbed(:valid_size, display_value: 'M')
    color = build_stubbed(:valid_color, name: 'Blue')

    variant = build_stubbed(:valid_imprintable_variant,
                                 imprintable_id: imprintable.id,
                                 color_id: color.id,
                                 size_id: size.id)

    allow(variant).to receive_message_chain(:size, :display_value).and_return('M')
    allow(variant).to receive_message_chain(:size, :id).and_return size.id
    allow(variant).to receive_message_chain(:color, :name).and_return 'Blue'
    allow(variant).to receive_message_chain(:color, :id).and_return color.id
    allow(variant).to receive(:name).and_return 'Blue'

    render 'imprintables/show/sizing',
           {
               imprintable: imprintable,
               variants_array: [variant, variant],
               color_variants: [variant, variant],
               size_variants: [variant]
           }
  end

  it 'should display a table of available size and colors with 2 variants' do
    expect(rendered).to have_selector('.table-responsive')
    expect(rendered).to have_css('td', text: 'Blue')
    expect(rendered).to have_css('th', text: 'M')
    expect(rendered).to have_css('.fa.fa-check-square', count: 2)
  end
end
