require 'spec_helper'

describe 'imprintables/_edit_sales_info.html.erb', imprintable_spec: true do

  let(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    f = test_form_for imprintable, builder: LancengFormBuilder
    mch = {
            brand_collection: [],
            store_collection: [],
            imprintable_collection: [],
          }
    render partial: 'imprintables/edit_sales_info',
           locals: {
                     imprintable: imprintable,
                     f: f,
                     model_collection_hash: mch
                   }
  end

  context 'without imprintable variants' do 
    it 'contains a warning that you cannot add imprint groups' do 
      expect(rendered).to have_text("cannot add imprintable groups")
    end
  end
  
  context 'with imprintable variants' do
    let(:imprintable) { build_stubbed(:valid_imprintable, imprintable_variants: [build_stubbed(:valid_imprintable_variant)])  }
    
    it 'does not contain a warning that you cannot add imprint groups' do 
      expect(rendered).to_not have_text("cannot add imprintable groups")
    end
  end

  it 'has field for brand, style name, catalog no, description' do
    within_form_for Imprintable, noscope: true do
      expect(rendered).to have_field_for :standard_offering
      expect(rendered).to have_field_for :tag_list
      expect(rendered).to have_field_for :sample_location_ids
      expect(rendered).to have_field_for :coordinate_ids
      expect(rendered).to have_content 'Add Imprintable Category'
      expect(rendered).to have_field_for :main_supplier
      expect(rendered).to have_field_for :supplier_link
      expect(rendered).to have_field_for :base_price
      expect(rendered).to have_field_for :xxl_price
      expect(rendered).to have_field_for :xxxl_price
      expect(rendered).to have_field_for :xxxxl_price
      expect(rendered).to have_field_for :xxxxxl_price
      expect(rendered).to have_field_for :xxxxxxl_price
    end
  end
end
