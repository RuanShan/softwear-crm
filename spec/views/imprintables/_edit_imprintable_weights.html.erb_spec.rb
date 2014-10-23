require 'spec_helper'

describe 'imprintables/_edit_imprintable_weights.html.erb', imprintable_spec: true do

  let(:imprintable) { create(:valid_imprintable) }

  before(:each) do

    render partial: 'imprintables/edit_imprintable_weights',
           locals: {
                     imprintable: imprintable,
                     size_variants: [],
                   }
  end

  it 'has field for brand, style name, catalog no, description' do
    imprintable.sizes.each do |size|
      expect(rendered).to have_selector("#imprintable_variant_weights_#{size.id}")
    end
  end
end
