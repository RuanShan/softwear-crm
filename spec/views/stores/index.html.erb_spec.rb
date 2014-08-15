require 'spec_helper'

describe 'stores/index.html.erb', store_spec: true do
  before(:each) do
    assign(:stores, [build_stubbed(:valid_store)])
    render
  end

  it 'has a table of stores' do
    expect(rendered).to have_selector('table#stores_list')
  end

  it 'has a form to create a store' do
    expect(rendered).to have_selector("form[action='#{stores_path}'][method='post']")
  end
end
