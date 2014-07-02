require 'spec_helper'

describe 'stores/new.html.erb', store_spec: true do
  it 'has a form to create a new store' do
    assign(:store, Store.new)
    render
    expect(rendered).to have_selector("form[action='#{stores_path}'][method='post']")
  end
end