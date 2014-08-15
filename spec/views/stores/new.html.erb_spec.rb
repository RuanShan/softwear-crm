require 'spec_helper'

describe 'stores/new.html.erb', store_spec: true do
  before(:each) do
    assign(:store, Store.new)
    render
  end

  it 'has a form to create a new store' do
    expect(rendered).to have_selector("form[action='#{stores_path}'][method='post']")
  end
end