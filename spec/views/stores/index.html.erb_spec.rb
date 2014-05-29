require 'spec_helper'

describe 'stores/index.html.erb' do

  it 'has a table of stores' do
    assign(:stores, Store.all)
    render
    expect(rendered).to have_selector("table#stores_list")
  end

  it 'has a form to create a store' do
    assign(:stores, Store.all)
    render
    expect(rendered).to have_selector("form[action='#{stores_path}'][method='post']")
  end

end