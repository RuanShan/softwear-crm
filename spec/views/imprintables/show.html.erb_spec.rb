require 'spec_helper'

describe 'imprintables/show.html.erb', imprintable_spec: true do
  let!(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    assign(:imprintable, imprintable)
    allow(imprintable).to receive_message_chain(:brand, :name).and_return('brand name')
    assign(:variants_hash, { size_variants: [], color_variants: [], variants_array: [] })
    render file: 'imprintables/show', id: imprintable.to_param
  end

  context 'The imprintable is not part of the standard product set' do
    it 'has a tabbed display with basic info, size/color availability,
        imprint details, and supplier information listed' do
      expect(rendered).to have_selector("#sales_info_#{imprintable.id}")
      expect(rendered).to have_selector("#production_info_#{imprintable.id}")
      expect(rendered).to have_selector("#sizing_info_#{imprintable.id}")
      expect(rendered).to_not have_content 'This Imprintable is part of the Standard Product Set'
    end
  end

  context 'The imprintable is part of the standard product set' do
    let!(:imprintable) { build_stubbed(:valid_imprintable, standard_offering: true) }

    before(:each) do
      render file: 'imprintables/show', id: imprintable.to_param
    end

    it 'displays the standard product notice' do
      expect(rendered).to have_content 'This Imprintable is part of the Standard Product Set'
    end
  end
end
