require 'spec_helper'

describe 'imprintables/_size_color_availability.html.erb', imprintable_spec: true do
  login_user

  it 'should display a table of available size and colors with 2 variants' do
    imprintable = create(:valid_imprintable)
    size = create(:valid_size, display_value: 'M')
    color_one = create(:valid_color, name: 'Blue')
    color_two = create(:valid_color, name: 'Red')
    variant_one = ImprintableVariant.create(imprintable_id: imprintable.id, color_id: color_one.id, size_id: size.id)
    variant_two = ImprintableVariant.create(imprintable_id: imprintable.id, color_id: color_two.id, size_id: size.id)
    render partial: 'imprintables/size_color_availability', locals: { imprintable: imprintable,
                                                                      variants_array: [variant_one, variant_two],
                                                                      color_variants: [color_one, color_two],
                                                                      size_variants: [size] }
    expect(rendered).to have_selector('.table-responsive')
    expect(rendered).to have_css('td', text: 'Blue')
    expect(rendered).to have_css('th', text: 'M')
    expect(rendered).to have_css('.fa.fa-check-square', count: 2)
  end
end
