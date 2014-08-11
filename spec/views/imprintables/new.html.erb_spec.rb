require 'spec_helper'

describe 'imprintables/new.html.erb', imprintable_spec: true do
  it 'has a form to create a new imprintable' do
    assign(:imprintable, Imprintable.new)
    assign(:model_collection_hash, { brand_collection: [], store_collection: [], imprintable_collection: [], size_collection: [], color_collection: [], sizing_categories_collection: [], imprint_method_collection: [] })
    render
    expect(rendered).to have_selector("form[action='#{imprintables_path}'][method='post']")
  end
end