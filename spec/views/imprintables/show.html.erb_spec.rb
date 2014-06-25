require 'spec_helper'

describe 'imprintables/show.html.erb', imprintable_spec: true, new: true do
  before(:each) do
    assign(:size_variants, [])
    assign(:color_variants, [])
    assign(:variants_array, [])
  end

  context 'The imprintable is not part of the standard product set' do
    let!(:imprintable) { create(:valid_imprintable) }
    login_user

    it 'has a tabbed display with basic info, size/color availability, imprint details, and supplier information listed' do
      assign(:imprintable, imprintable)

      render file: 'imprintables/show', id: imprintable.to_param
      expect(rendered).to have_selector("#basic_info_#{imprintable.id}")
      expect(rendered).to have_selector("#size_color_availability_#{imprintable.id}")
      expect(rendered).to have_selector("#imprint_details_#{imprintable.id}")
      expect(rendered).to have_selector("#supplier_information_#{imprintable.id}")
      expect(rendered).to_not have_content 'This Imprintable is part of the Standard Product Set'
    end
  end

  context 'The imprintable is part of the standard product set' do
    let!(:imprintable) { create(:valid_imprintable, standard_offering: true) }
    login_user

    it 'displays the standard product notice' do
      assign(:imprintable, imprintable)
      render file: 'imprintables/show', id: imprintable.to_param, locals: { color_variants: [], size_variants: [], variants_array: [] }
      expect(rendered).to have_content 'This Imprintable is part of the Standard Product Set'
    end
  end
end
