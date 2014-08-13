require 'spec_helper'

describe 'imprintables/edit.html.erb', imprintable_spec: true do
  let(:imprintable) { build_stubbed(:valid_imprintable) }

  before(:each) do
    allow(imprintable).to receive(:name).and_return('name')
    assign(:imprintable, imprintable)
    assign(:model_collection_hash,
           {
             brand_collection: [],
             store_collection: [],
             imprintable_collection: [],
             imprint_method_collection: [],
             all_colors: [],
             all_sizes: []
           }
    )
    render
  end

  it 'has a form to create a new mockup group' do
    expect(rendered).to have_selector("form[action='#{imprintable_path(imprintable)}'][method='post']")
  end
end
