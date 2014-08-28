require 'spec_helper'

describe 'imprintables/new.html.erb', imprintable_spec: true do
  before(:each) do
    assign(:imprintable, Imprintable.new)
    assign(:instance_hash,
           {
             model_collection_hash:
               {
                   brand_collection: [],
                   store_collection: [],
                   imprintable_collection: [],
                   imprint_method_collection: [],
                   all_colors: [],
                   all_sizes: []
               }
           }
    )
    render
  end

  it 'has a form to create a new imprintable' do
    expect(rendered).to have_selector('form#new_imprintable')
  end
end
