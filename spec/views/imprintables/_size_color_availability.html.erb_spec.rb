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
                                                                      color_variants: [variant_one, variant_two],
                                                                      size_variants: [variant_one] }
    expect(rendered).to have_selector('.table-responsive')
    expect(rendered).to have_css('td', text: 'Blue')
    expect(rendered).to have_css('th', text: 'M')
    expect(rendered).to have_css('.fa.fa-check-square', count: 2)
  end

  it 'should only display the associated styles and colors' do
    imprintable = create(:valid_imprintable)
    size_one = create(:valid_size, display_value: 'M')
    size_two = create(:valid_size, display_value: 'nope')
    color_one = create(:valid_color, name: 'Red')
    color_two = create(:valid_color, name: 'Blue')
    variant_one = ImprintableVariant.create(imprintable_id: imprintable.id, color_id: color_one.id, size_id: size_one.id)
    allow(Size).to receive(:all).and_return( [size_one, size_two] )
    allow(Color).to receive(:all).and_return( [color_one, color_two] )
    render partial: 'imprintables/size_color_availability', locals: { imprintable: imprintable,
                                                                      variants_array: [variant_one],
                                                                      color_variants: [variant_one],
                                                                      size_variants: [variant_one] }

    expect(rendered).to have_selector('.table-responsive')
    expect(rendered).to have_css('td', text: 'Red')
    expect(rendered).to have_css('th', text: 'M')
    expect(rendered).to_not have_css('td', text: 'nope')
    expect(rendered).to_not have_css('th', text: 'Blue')
  end
end
