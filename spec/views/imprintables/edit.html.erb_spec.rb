require 'spec_helper'

describe 'imprintables/edit.html.erb', imprintable_spec: true do
  let(:imprintable){ create(:valid_imprintable) }

  it 'has a form to create a new mockup group' do
    assign(:imprintable, imprintable)
    assign(:model_collection_hash, { brand_collection: [], store_collection: [], imprintable_collection: [], size_collection: [], color_collection: [], imprint_method_collection: [], all_colors: [], all_sizes: [] })
    render file: 'imprintables/edit', id: imprintable.to_param
    expect(rendered).to have_selector("form[action='#{imprintable_path(imprintable)}'][method='post']")
  end
end
